---
layout: post
title: Efficient reading and writing with AWS S3
image: "/assets/efficient-s3/get-put-object.webp"
tags:
- data
- programming
- code
- lambda
- aws
- etl
- efficiency
- aws-s3
- cloud-computing
- performance-optimization
- serverless
- best-practices
- cost-optimization
- streaming
- multipart-upload
date: 2025-02-12 15:52 +0000
---
Back in January 2024 I wrote a post about [efficiently writing to S3 in
Python]({% post_url 2024-01-31-efficiently-writing-to-s3-in-python %}) that has
become relatively popular on this blog (thanks to [GoatCounter]({% post_url
2024-12-10-adding-privacy-friendly-tracking-to-my-blog %}) for revealing this.)
So I thought I'd take a broader look at the most efficient ways to read and
write from S3 with special attention paid to AWS Lambdas and
resource-constrained containers in general.

I won't be giving detailed code examples in this post as I want to focus on
general best practices for reading and writing data in S3 efficiently. 

## GetObject and PutObject

First off it's worth addressing the simplest ways of reading and writing to S3,
[GetObject](https://docs.aws.amazon.com/AmazonS3/latest/API/API_GetObject.html)
and
[PutObject](https://docs.aws.amazon.com/AmazonS3/latest/API/API_PutObject.html).

<img
  title='GetObject gets from S3 Buckets, PutObject puts to S3 Buckets'
  src='{{ "assets/efficient-s3/get-put-object.webp" | absolute_url }}'
  class='blog-image'
/>

Both are perfectly adequate in most scenarios. Whatever programming language
you are using will likely have [language
bindings](https://aws.amazon.com/developer/tools/) for both of these API
endpoints, be it
[Python](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/s3.html),
[Java](https://sdk.amazonaws.com/java/api/latest/),
[Rust](https://crates.io/crates/aws-sdk-s3),
[Go](https://github.com/aws/aws-sdk-go-v2) or
[JavaScript](https://github.com/aws/aws-sdk-js-v3).

`GetObject` will return the whole object to you via a HTTP request, with the
body of the response being the contents of the object. Likewise `PutObject`
expects the body of your request to be the object you'd like to upload.

There are performance considerations you can make with just these two
operations.

For starters, if you can, you should stream the contents of `GetObject` through
your program. As an example, in Java based languages the API provides you with
a kind of
[InputStream](https://docs.oracle.com/javase/8/docs/api/java/io/InputStream.html),
which means you can use the full range of classes and wrappers for
`InputStream` instances, including an
[InputStreamReader](https://docs.oracle.com/javase/8/docs/api/java/io/InputStreamReader.html).
Similarly, in Python the `Body` of your
[get_object](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/s3/client/get_object.html)
response is streamable. So if what you're reading is some kind of textual
format you don't need to load it all into memory all at once.

A good example of this is if you are reading [line-separated
JSON](https://jsonlines.org/), that is each line in the object represents a
whole JSON object. You can stream each line and process it line by line in your
program rather than loading the whole file into memory. Other row based data
formats like CSV or Apache Avro are also prime targets for this kind of
optimised reading technique.

<img
  title='You can deal with the individual lines in this example faster than
  loading the whole object and then splitting it'
  alt='Diagram showing JSON Lines and difference between reading them all at
  once or one at a time in terms of memory use.'
  src='{{ "assets/efficient-s3/json-lines.webp" | absolute_url }}'
  class='blog-image'
/>

With `PutObject` you can make use of the temporary storage available to the
container your code is running in. In AWS Lambda this is known as [ephemeral
storage](https://aws.amazon.com/blogs/compute/using-larger-ephemeral-storage-for-aws-lambda/)
and is configurable separate to the memory of your Lambda instances. Instead of
keeping a large object in memory, you simply write out to the temporary storage
then perform a `PutObject` using that file. Most of the AWS libraries support
this simple process, and while it means you write twice, once locally and once
to S3, it's by far the simplest way of avoiding keeping a large object in
memory.

<img
  title='Each individual streamed chunk of data from the GetObject call can be
  dropped from memory quickly.'
  alt='Diagram visualising doing a streaming GetObject and a local storage
  PutObject'
  src='{{ "assets/efficient-s3/get-streamed-put-temp.webp" | absolute_url }}'
  class='blog-image'
/>

## Multipart Uploads

While using `PutObject` with a temporary file is very easy, you might want to
go a step further if you're short on temporary storage, don't want to touch it
all, or know you'll be uploading very large objects that you don't want to
incur the cost of writing the data twice. For this you can use [Multipart
upload](https://docs.aws.amazon.com/AmazonS3/latest/userguide/mpuoverview.html).

Multipart upload lets you upload a single S3 Object in many smaller parts and
it's suggested for uploading of objects that are 100 MB or larger.

Multipart uploads require several network requests but there are benefits to
this, namely that, on stable high-bandwidth connections, you can benefit from
uploading multiple parts of a large object simultaneously, and, on spottier
networks, you only need to retry the parts that fail to upload.

A downside of multipart uploads is that you cannot add any custom metadata to
an object being uploaded after the upload has begun. This means that, for
example, if you are generating a count of results based on some computation
that is ongoing, you cannot tag the S3 object with that metadata when it
completes.

Multipart uploads can have a maximum of 10,000 parts, with each part having a
maximum size of 5GiB. Up to date limits can be read
[here](https://docs.aws.amazon.com/AmazonS3/latest/userguide/qfacts.html), but
as of time of writing a single S3 object can be up to 5 TiB in size.

Aside from the last part (which can also be the only part), each part must be
at least 5 MiB in size. This means that your program needs at least 5 MiB of
free memory to properly make use of multipart uploads. If your resources are so
constrained that you don't have 5 MiB to spare, you should opt for `PutObject`
and use your temporary storage for large file uploads.

To perform multipart uploads, you first need to call
[CreateMultipartUpload](https://docs.aws.amazon.com/AmazonS3/latest/API/API_CreateMultipartUpload.html)
with the bucket and key you want to upload to. You will then get a response
containing an `UploadId` to use. Next you will upload each part with
[UploadPart](https://docs.aws.amazon.com/AmazonS3/latest/API/API_UploadPart.html),
using the correct `UploadId` and part numbers. Finally you call
[CompleteMultipartUpload](https://docs.aws.amazon.com/AmazonS3/latest/API/API_CompleteMultipartUpload.html).
Of course, things can go wrong with multipart uploads so you can use
[AbortMultipartUpload](https://docs.aws.amazon.com/AmazonS3/latest/API/API_AbortMultipartUpload.html)
to abort the upload, but be sure to read the caveats associate with this in
regards to ongoing uploads.

<img
  title='Multipart uploads are very simple.'
  alt='Diagram visualising doing a multipart upload'
  src='{{ "assets/efficient-s3/multipart-upload-process.webp" | absolute_url }}'
  class='blog-image'
/>

If you want to use as little memory as possible in your program and know that
your uploaded file is going to be less than 48.82 GiB (i.e. 50,000 MiB), you
should upload parts of the minimum 5 MiB size. Even if what you are uploading
is less 100 MiB this will allow your program to only store roughly 5 MiB of
data to upload at any one time.

<img
  title='You can minimise both temporary storage and main memory when doing
  small multipart uploads.'
  alt='Diagram visualising doing a multipart upload in terms of minimal memory
  use when using 5 MiB part sizes.'
  src='{{ "assets/efficient-s3/multipart-upload-memory.webp" | absolute_url }}'
  class='blog-image'
/>

Something else you can do with multipart uploads is use existing S3 objects, or
even parts of them, as part of your upload by using
[UploadPartCopy](https://docs.aws.amazon.com/AmazonS3/latest/API/API_UploadPartCopy.html).
This can be useful if you are combining objects, sampling them or extracting
the headers out of them.

## Combining it all together

For a memory efficient program that both reads and writes to S3 you probably
want to be both reading data via streaming and writing data via some kind of
streaming mechanism like a multipart upload at the same time. However, exactly
how you achieve this will heavily depend on the container of your code.

### Efficient Lambdas

For an efficient AWS Lambda, your choice depends on what resources you are
willing to commit to each Lambda instance and the size of objects it will be
reading and writing.

#### Small S3 Objects

If you're only ever writing small S3 objects, that is those under 100 MiB, and
will be reading similarly sized objects, you can likely forgo multipart upload
logic and make use of ephemeral storage space and use a simple `GetObject` (with
streaming logic if possible) and `PutObject` based approach. This would let you
use less main memory in your overall Lambda and keep the invocations cheaper.
This will work especially well if your Lambdas only need under 512 MiB of
ephemeral storage space as that is provided at no cost by AWS.

If you really want to reduce the memory consumption of your Lambda, and what
you're implementing can be done in a streaming fashion, you should use a
multipart upload approach, even if the S3 objects will still be relatively
small (at least 15 MiB big). This allows you to not incur any extra costs for
ephemeral storage, provided you can spare at least 5 more MiB of memory for
each Lambda.

#### Larger S3 Objects

You should also use the above approach when dealing with larger S3 objects, but
can tune your part sizes above the 5 MiB minimum depending on how much larger
the objects are, how well your lambdas perform and how much memory you are
willing to give each Lambda instance. A good tool for tuning the latter is
[aws-lambda-power-tuning](https://github.com/alexcasalboni/aws-lambda-power-tuning),
and you could go a step further and graph similar tests for tuning the part
sizes.

#### Language Choice

Lastly, if you want to squeeze the most performance out of your Lambdas you
should really consider what programming language your code is written in.
Unfortunately, languages like Python, Java and C# have much higher overheads
thanks to their runtime environments. A large issue with these languages is
Cold Starts-when a Lambda instance is first created. This is because a Cold
Start requires the runtime environment to be setup. Luckily, AWS have something
called [Lambda
SnapStart](https://docs.aws.amazon.com/lambda/latest/dg/snapstart.html) that
can alleviate this issue, unfortunately, SnapStart doesn't work with ephemeral
storage sizes above 512 MiB.

<img
  title="Preferring compiled languages for performance efficiency doesn't mean
  the non-preferred languages are bad."
  src='{{ "assets/efficient-s3/language-considerations.webp" | absolute_url }}'
  class='blog-image'
/>

For the most efficient Lambdas you should be looking into using compiled
languages like
[Go](https://docs.aws.amazon.com/lambda/latest/dg/lambda-golang.html) and
[Rust](https://docs.aws.amazon.com/lambda/latest/dg/lambda-rust.html) or using
some other language that can be run with the [OS-only Lambda
runtime](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-provided.html)
(like C, C++, or even Zig). The reason for this is the same reason compiled
code normally outperforms virtual machine based or interpreted code, it runs
directly on the hardware. The binaries produced by these languages will often
be much smaller in size and memory footprint than the most optimised VM based
language. In the case of Rust, no garbage collection is done so memory is freed
as soon as possible, but even with garbage collection in Go you'll still see
much faster Lambdas than the likes of C# and Java thanks to the compiled nature
of the code.

I would caution against rewriting all your Lambdas into a compiled language
though, especially into Rust. As the time and memory saved may not be worth it
in terms of learning, debugging and supporting an unfamiliar language. Using
SnapStart and following the [best
practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
will get you a long way even in one of the less efficient languages.

#### Lambda Running Time

When writing Lambdas you need to be aware of how long your individual
invocations will run for since AWS limits each invocation to a maximum of 15
minutes. This post is primarily about reading and writing from S3 so I won't go
into too much detail about working within this restriction, but the main way to
do this is to keep your Lambdas lean. Make sure they are performing the
smallest possible action while remaining idempotent and atomic. When it
comes to S3, that tends to mean your Lambda should ideally be reading a single
S3 object and/or writing a single S3 object. If you find your Lambda needs
to read and write many S3 objects you may want to split it.

#### Big-O

You should think of this in terms similar to [Big O
notation](https://www.bigocheatsheet.com/) when it comes to the number of S3
objects being read and written. Specifically, your Lambda code should generally
be `O(1)` if possible or `O(n)` if not. Reading and/or writing single S3
objects is the ideal.

<img
  title='Various Big Os'
  alt='Diagram showing Big O notations'
  src='{{ "assets/efficient-s3/big-o.svg" | absolute_url }}'
  class='blog-image'
/>

The above diagram is a reminder that once you move beyond `O(n)` small
increases can drastically increase computation.

## Conclusion

To summarise, the most efficient way to read and write to S3 heavily depends on
the specific constraints of the container of your program such as main memory,
local storage, processing power, and time limits.

You should:

- Prefer streaming reads when possible, so you aren't holding large objects in
  memory
- Offload to temporary storage for writes to avoid holding data that you are
  done processing in memory
- Leverage multipart uploads for large uploads and to avoid holding onto data
  in both main memory and local storage
- Keep your lambdas lean and their operations efficient
- Optimise your choice of language for writing Lambdas, if possible, or use
  best practices and features like SnapStart to reduce the impact of your
  language runtime.

While trying to follow these steps, you should be pragmatic. The most optimal
decision isn't always the most memory- or operation-efficient; often, it
depends on your expertise and non-functional requirements.

You should also benchmark your approaches to identify bottlenecks and their
impact on efficiency. Collecting such metrics will save you time in the long
run, as code often only needs to reach a 'good enough' state rather than
perfection.

Ultimately, efficiently reading and writing to S3 requires understanding how
your program interacts with data- its access patterns, memory usage, and
constraints. By modeling these behaviors and applying the right techniques, you
can significantly improve performance and resource efficiency. Experiment with
different configurations, benchmark your approach, and refine your
implementation to find what works best for your use case.
