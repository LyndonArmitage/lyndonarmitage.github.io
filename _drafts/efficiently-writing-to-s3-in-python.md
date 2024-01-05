---
layout: post
title: Efficiently writing to S3 in Python
tags:
- python
- data
- programming
- code
- json
- ingest
- lambda
- aws
---

Before Christmas 2023 we ran into an issue with one of our simpler data ingests
at work. An [AWS Lambda](https://aws.amazon.com/lambda/), written in
[Python](https://www.python.org/) that queried an API, transformed the results,
and landed them in [Amazon S3](https://aws.amazon.com/s3/) as
[JSON](https://www.json.org/) (gzipped [JSON Lines
files](https://jsonlines.org/) to be specific), started to fail.

This data ingest was part of a larger framework written in Python that had
other lambdas running and working fine, which skewed investigation toward there
being some change in the API or its output that was causing the outage.

## Initial Investigation & Triage

Looking at the logs the issue was quick to reveal itself:

```txt
Error: Runtime exited with error: signal: killed
```

The Python process was being killed by the Lambda runtime.

Having seen issues like this before, we investigated the logs a little more and
saw the telltale reason why the Lambda had been killed:

```txt
Memory Size: 4096 MB	Max Memory Used: 4096 MB
```

**It ran out of memory.**

This was a bit perplexing, the data it was responsible for outputting to S3 was
very small, in fact it amounted to a JSON file that totaled 1.6G unzipped
normally, and the process normally ran in less than a minute.

**In the interest of triage, the lambda was temporarily given more memory.** I
was reluctant for this to be the final solution to the problem because I was
aghast that less than 2G worth of JSON should need so much memory. **This
patched the issue temporarily**.

Ideally, we could have detected this increase in memory usage via the metrics
published by [Lambda
Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Lambda-Insights-metrics.html)
but these enhanced metrics were not turned on for this specific lambda.

## More Investigation

Looking further into the logs and Lambda memory use revealed that on previous
days it had been using a little less memory:

```txt
Memory Size: 4096 MB	Max Memory Used: 3324 MB
```

And poking the API it ingested data from and the Lambdas previous output
revealed that its output had increased in volume from the previous days:

```txt
2023-12-10 05:42:53   70.5 MiB date=2023-12-10/variants.jsonl.gz
2023-12-11 05:42:48   70.4 MiB date=2023-12-11/variants.jsonl.gz
2023-12-12 05:43:03   70.4 MiB date=2023-12-12/variants.jsonl.gz
2023-12-13 05:42:33   70.7 MiB date=2023-12-13/variants.jsonl.gz
2023-12-14 05:42:43   70.8 MiB date=2023-12-14/variants.jsonl.gz
2023-12-15 05:42:26   70.8 MiB date=2023-12-15/variants.jsonl.gz
2023-12-16 05:42:32   70.8 MiB date=2023-12-16/variants.jsonl.gz
2023-12-17 05:42:36   70.8 MiB date=2023-12-17/variants.jsonl.gz
2023-12-18 05:42:42   70.8 MiB date=2023-12-18/variants.jsonl.gz
2023-12-19 05:42:25   70.8 MiB date=2023-12-19/variants.jsonl.gz
2023-12-20 05:42:03   70.8 MiB date=2023-12-20/variants.jsonl.gz
2023-12-21 13:28:09  109.3 MiB date=2023-12-21/variants.jsonl.gz
```

Actually downloading the files from the 20th and 21st (after the successful
rerun with increased memory) and performing a simple line count revealed the
record count had not changed from 83,688, but the width per record had
increased instead. It also revealed an increase in unzipped size from `1.6G` to
`2.4G`.

So **the catalyst for the error was a change in the fields in the APIs
output**. Still, a good data ingest process should be resilient and scale
nicely as data volumes increase.

Having exhausted the avenues of input and output investigation, it was finally
time to investigate the actual Python code of the ingestion Lambda.

## Python Strings & Performant Writing to S3

I can't share the full proprietary code of the lambda for obvious reasons but
sufficed to say it was well organised, being built on a framework for API
ingests.

Specific implementations for APIs in this framework could optionally override
how the framework collected their results, which is exactly what this lambda
had done.

It was a fairly simple process:

- Query a paged endpoint
- Do some small data transformations on the returned data (mostly amounting to
  aligning date and time-stamp types)
- Convert the Python dictionary objects to JSON strings
- Concatenate to a string
- Write the string to Amazon S3

The relevant Python looked like this:

```py
def build_json_string(self, modified_data):
    return '\n'.join(json.dumps(element) for element in modified_data) + '\n'

def get_data(self):
    try:
        ingest_date = self.get_ingest_date()
        ingest_ts = self.get_ingest_ts()

        self.build_api_url(self.count, self.token)
        variants = self.retrieve_api_response()

        self.modify_variants(variants, ingest_date, ingest_ts)

        all_data = self.build_json_string(variants)

        api_run_count = 1
        API_RUN_LIMIT = 450

        while api_run_count <= API_RUN_LIMIT:

            if api_run_count >= API_RUN_LIMIT:
                raise Exception("Too many calls made to API!")

            self.build_api_url(self.count, self.token)
            variants = self.retrieve_api_response()

            self.modify_variants(variants, ingest_date, ingest_ts)

            all_data += self.build_json_string(variants)
            api_run_count += 1

            if not self.token:
                break

    except Exception as e:
        raise Exception(f'Error occurred during the ingest - {e}')

    return all_data
```

Something important I noticed is that `all_data` is a Python string.

Python, like some other programming languages, uses **immutable strings**. That
means any modifications done to a string in Python actually create a brand new
string with the changes applied to them (in practice CPython might do some
[optimisations](https://en.wikipedia.org/wiki/String_interning) around this,
but the concept remains the same). *Horace Fayomi has written a detailed
tutorial
[post](https://dev.to/fayomihorace/python-how-simple-string-concatenation-can-kill-your-code-performance-2636)
about Python string concatenation if you are unfamiliar with this topic.*

So each `all_data += self.build_json_string(variants)` call will create a brand
new string as it is appending to the previous version of `all_data`.

This means that at the time of the append (the `+=`) Python allocates a new
string that is at least `len(all_data) + len(self.build_json_string(variants))`
large while keeping both `all_data` and `self.build_json_string(variants)` in
memory. So in the best case, **Python has reserved double the amount of
memory needed for the string before it can garbage collect the individual
constituent strings**.

So every iteration of the loop our memory footprint increases by that
iterations page of results, then doubles on the append, and finally shrinks
back down.

<img
  title='Diagram showing the doubling of memory when allocating a string in
  Python'
  alt='Diagram showing the doubling of memory when allocating a string in
  Python'
  src='{{ "assets/strings/string-doubling.webp" | absolute_url }}'
  class='blog-image'
/>

Eventually, when the API had been drained of results we return the full string
and another part of the Python code GZips the string and writes it out to
Amazon S3:

```py
# This is in a separate file

def fetch_and_upload_data(self):
    """
    Fetches the data from the relevant API call, 
    creates a gzip jsonl file in /tmp storage of the lambda function
    and uploads it to S3 bucket.
    The root prefix provided for the dataset is considered as the file 
    with .jsonl.gz extension
    """
    data = self.api_obj.get_data()
    
    file_root_prefix = self.s3_target_file 
    if not file_root_prefix:
        file_root_prefix = self.s3_root_prefix.replace("/", "_")
    file_name = f"/tmp/{file_root_prefix}.jsonl.gz"

    if data:
        with gzip.open(file_name, 'w') as zip_file:
            zip_file.write(data.encode('utf-8'))
        self.s3_client.upload_file(file_name)
        return True
    else:
        return False
```

Interestingly, the string is first written to a temporary file inside the
AWS Lambda before being uploaded. Since this file in particular amounts to just
~100M that hasn't become an issue yet but it could be one in the future.

So the upload process had no inherent memory related issues in it.

Lets focus back on the actual string concatenating code. What are some quick
wins we can do to improve its performance?

## Improving the Performance

The first thing that jumps to my mind is we can stop doing a string
concatenation every iteration of the loop.

Instead, we can store every API result in a Python list and do the string
concatenation once after iterating using join:

```py
def convert_to_json(self, data) -> list[str]:
    return (json.dumps(element) for element in data)

def get_data(self):

    json_lines = []

    try:
        ingest_date = self.get_ingest_date()
        ingest_ts = self.get_ingest_ts()

        self.build_api_url(self.count, self.token)
        variants = self.retrieve_api_response()

        self.modify_variants(variants, ingest_date, ingest_ts)

        json_lines = self.convert_to_json(variants)

        api_run_count = 1
        API_RUN_LIMIT = 450

        while api_run_count <= API_RUN_LIMIT:

            if api_run_count >= API_RUN_LIMIT:
                raise Exception("Too many calls made to API!")

            self.build_api_url(self.count, self.token)
            variants = self.retrieve_api_response()

            self.modify_variants(variants, ingest_date, ingest_ts)

            # Convert to JSON lines and append to the list
            json_lines.extend(self.convert_to_json(variants))

            api_run_count += 1

            if not self.token:
                break

    except Exception as e:
        raise Exception(f'Error occurred during the ingest - {e}')

    # Finally join all the JSON lines into a single string
    return "\n".join(json_lines) + "\n"
```

Admittedly, this seems to just **move the problem**. Now we grow memory
linearly throughout the loop and just incur the doubling at the end.
`join` is optimised to only create a single new string object in Python rather
than the multiples we'd been creating with `+=` in the loop. We still need to
allocate the same memory in the end, but there is less pressure on the garbage
collector in Python.

<img
  title='Diagram showing that this still doubles the memory, just once at the
  end.'
  alt='Diagram showing that this still doubles the memory, just once at the
  end.'
  src='{{ "assets/strings/string-doubling-once.webp" | absolute_url }}'
  class='blog-image'
/>

So doing this reduces the performance impact of the constant concatenation but
we will still run into memory issues due to the large string we eventually
create.

If you've read this far, you're probably screaming at your screen the obvious
solution to our memory issues: **Write out the rows as soon as we get them, and
avoid the whole mess of concatenation altogether.**

To recap the process; the API returns pages of results that we convert into
JSON strings and eventually write out to a Gzipped file before uploading to
Amazon S3. **There is no reason we have to fully drain the API results into the
Python programs memory before we start writing out.**

If we alter the contract between `get_data` and `fetch_and_upload_data` and
pass in the `zip_file` we are writing to, **we can write out each page of data
to disk as it comes** (after our transformations), and avoid storing the
related strings in memory beyond each iteration of the loop.

This would mean, the ingest lambda would only need enough memory to store a
page of results as opposed to all of them. The potential disk space problem
still remains however, but we will address that later.

<img
  title='This actually makes intuitive sense when you consider how the data
  looks inside the lambda.'
  alt='Diagram showing the difference in memory size between the original
  solution and proposed paging solution.'
  src='{{ "assets/strings/original-vs-paging.webp" | absolute_url }}'
  class='blog-image'
/>

Since this lambda ingest is part of a framework the changes were a bit more
involved (other ingests use the same writing code) but essentially it boils
down to 2 changes (recreated as best I can below).

First `fetch_and_upload_data` is changed to pass the file to the `api_obj`:

```py
def fetch_and_upload_data(self):
    file_root_prefix_ = self.s3_target_file 
    if not file_root_prefix:
        file_root_prefix = self.s3_root_prefix.replace("/", "_")
    file_name = f"/tmp/{file_root_prefix}.jsonl.gz"
    
    wrote_data = False
    with gzip.open(file_name, 'w') as zip_file:
        wrote_data = self.api_obj.write_data(zip_file)
    
    if wrote_data:
        self.s3_client.upload_file(file_name)
        return True
    else:
        return False
```

Then the implementation of the `api_obj` is changed to write instead of return:

```py
def write_to_file(self, data, file):
    new_line = '\n'.encode('utf-8')
    for element in data:
        json_line = json.dumps(element)
        file.write(json_line.encode('utf-8'))
        file.write(new_line)

def write_data(self, file):
    try:
        ingest_date = self.get_ingest_date()
        ingest_ts = self.get_ingest_ts()

        self.build_api_url(self.count, self.token)
        variants = self.retrieve_api_response()

        self.modify_variants(variants, ingest_date, ingest_ts)
        # Write out the first page
        self.write_to_file(variants, file)

        api_run_count = 1
        API_RUN_LIMIT = 450

        while api_run_count <= API_RUN_LIMIT:

            if api_run_count >= API_RUN_LIMIT:
                raise Exception("Too many calls made to API!")

            self.build_api_url(self.count, self.token)
            variants = self.retrieve_api_response()

            self.modify_variants(variants, ingest_date, ingest_ts)
            # Write out the page
            self.write_to_file(variants, file)

            api_run_count += 1

            if not self.token:
                break

    except Exception as e:
        raise Exception(f'Error occurred during the ingest - {e}')
    return True
```

You can see I opted to rename the function in question so it is clear what it
is doing. I've kept a light touch around the rest of the code though.

With this change, the potential issue with the ephemeral `/tmp` disk storage
still remains. Currently, **the lambda will be killed when we try to write a
file that exceeds the lambdas allotted temporary storage limit**.

In practice this isn't an issue since most APIs we query will never produce
GZipped files that exceed the lambdas current free limits (512 MB). If we
wanted to be thorough we could dive into the S3 client code and instead of
exposing the file to the API ingestion framework, we could expose some kind
output stream to write to and upload to S3 using a multipart upload or via
[upload_fileobj](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/s3/client/upload_fileobj.html)
(which handles this complexity for us).

There is still some room for improvement in the above code, but the changes
made eliminate the memory issue, and also consequently reduce the cost of
executing the lambda. There could be further cost savings made with the above
suggestion around bypassing writing to disk completely, but this could become
an exercise in [yak shaving](https://americanexpress.io/yak-shaving/) very
quickly without performing any meaningful measurements, especially given the
price of [Ephemeral storage on
AWS](https://aws.amazon.com/lambda/pricing/#Lambda_Ephemeral_Storage_Pricing)
and that before these changes our API lambda invocations were normally running
within a minute. It could potentially save some execution time (by avoiding
disk based IO) but the added complexity may not be worth the development and
potential debugging time.

Hopefully this post serves as a gentle reminder that **memory is not
infinite**, how being conscious of this can help save both time and money, and
how executing in the cloud doesn't absolve you of these responsibilities.
