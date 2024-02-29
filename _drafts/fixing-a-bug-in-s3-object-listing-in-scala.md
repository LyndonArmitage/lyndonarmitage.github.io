---
layout: post
title: Fixing a bug in S3 Object listing in Scala
tags:
- scala
- code
- programming
- aws
- amazon
- api
- testing
---

This is a quick tip from a blunder I made when writing some Scala code using
the [AWS S3 object listing
API](https://docs.aws.amazon.com/AmazonS3/latest/API/API_ListObjectsV2.html).
Hopefully it will save someone else from making the same mistake and show how
important it is to have good tests, a clear API and the literacy skills to read
it.

Recently, I wrote some code to perform a large listing on some objects
stored in Amazon S3, filter them, and transform the results in some way.

Being a smart alec I opted to write my code using tail-recursion and other
fancy functional accoutrements:

```scala
@tailrec
private def getObjects[T](
    request: ListObjectsV2Request,
    results: ArrayBuffer[T],
    conversionFun: S3ObjectSummary => T,
    filterFun: (S3ObjectSummary, T) => Boolean = { (_, _: T) => true }
): ArrayBuffer[T] = {
  val result = s3.listObjectsV2(request)

  // convert to the internal type and filter
  val objects = result.getObjectSummaries.asScala
    .map(sum => (sum, conversionFun(sum)))
    .filter { case (sum, obj) => filterFun(sum, obj) }
    .map(_._2)

  // Resize the results buffer to reduce number of resizes
  results.sizeHint(results.size + objects.size)
  results.appendAll(objects)
  if (!result.isTruncated) {
    results
  } else {
    getObjects(
      request.withContinuationToken(result.getContinuationToken()),
      results,
      conversionFun,
      filterFun
    )
  }
}
```

Looks fine right? Actually, I think it looks quite elegant; it demonstrates
recursion rather well and could be pretty good demonstration of the DRY (Don't
repeat yourself) principles.

However, and to my shock horror, this code continuously executes!

If you're familiar with the AWS Java SDK you can probably see my error:
`result.getContinuationToken()` returns the current results continuation token,
**not the next continuation token to use!** For this I'd need to use 
`result.getNextContinuationToken()`. 

The original behaviour results in an infinite loop of requests being made for
the first page of results, as `result.getContinuationToken()` will return
`null` for the first set of results.

So, for completeness, the correct code looks like this:

```scala
@tailrec
private def getObjects[T](
    request: ListObjectsV2Request,
    results: ArrayBuffer[T],
    conversionFun: S3ObjectSummary => T,
    filterFun: (S3ObjectSummary, T) => Boolean = { (_, _: T) => true }
): ArrayBuffer[T] = {
  val result = s3.listObjectsV2(request)

  // convert to the internal type and filter
  val objects = result.getObjectSummaries.asScala
    .map(sum => (sum, conversionFun(sum)))
    .filter { case (sum, obj) => filterFun(sum, obj) }
    .map(_._2)

  // Resize the results buffer to reduce number of resizes
  results.sizeHint(results.size + objects.size)
  results.appendAll(objects)
  if (!result.isTruncated) {
    results
  } else {
    getObjects(
      request.withContinuationToken(result.getNextContinuationToken()),
      results,
      conversionFun,
      filterFun
    )
  }
}
```

I use the AWS Java SDK a lot, so how'd I make this mistake? I speed-read the 
documentation for the API and made unfounded assumptions. Not only that, but
all my testing was done against short lists of objects that were never more
than 1000 objects long!

Ultimately, the mistake lies with me but there are some lessons that can be
taken away from this experience:

1. Write thorough tests for all your code paths
2. Write your own APIs in a way that minimises the surface area for user error
3. Read the API docs carefully, even when you're used to them

I've put these in order of importance.

Obviously, my issue would have reared its head earlier had I written a thorough
test for this piece of code. This code is a `private` function though, so my
tests would need to be testing whatever public facing code utilises this
function thoroughly. They would also need to do volumetric testing, and pass in
inputs that should produce large expected outputs.

When writing APIs you should consider what could be confusing to a user.
[Joshua Bloch gave an excellent talk on this in
2007](https://www.youtube.com/watch?v=aAb7hSCtvGw). 

A key point in API design is being unambiguous. In the case of this AWS SDK API
I'd have considered naming the field on the response/result from the
`listObjectsV2` function `LastContinuationToken` rather than just
`ContinuationToken`, at the cost of 4 letters you can be specific about what
that field was. You might argue the fact that when put next to
`NextContinuationToken` it is pretty clear that `ContinuationToken` means the
current or previous token, but you are assuming the context that your API
consumer is in will make that apparent.

Likewise, you should consider the common tasks users will perform with your
API. I expect it was a conscious decision to not include some helper function
in the AWS Java SDK for getting and/or filtering large lists of S3 objects with
a single API call (likely to keep it close to the HTTP API), this is a fine
decision, and Josh mentions in his talk about trying to keep all consumers of
your API suitably unhappy, but when designing your own APIs you should consider
giving simple methods for your users to achieve universally common tasks.

Finally, reading API docs carefully yourself can help prevent misuse of them
This doesn't just include the inline documentation with code but also any kind
of outside the editor documentation as well. These documents can often contain
examples that will show you how an API designer intended you to use their API.
