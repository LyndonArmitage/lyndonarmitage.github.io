---
layout: post
title: I Don't Like Mocks
tags:
- programming
- opinion
- mocking
- mocks
- stubs
- testing
- tests
date: 2023-10-12 16:00 +0100
---
I don't like software Mocks or Mocking frameworks in general. In my experience
they don't really help when it comes to testing software, at least the kind I
work on, and the frameworks themselves are a nightmare to deal with.

To preface this, I've spent the majority of my career working in high level
programming languages like Java, Scala, Kotlin and JavaScript, so my experience
with Mocks is coloured by how they work in these languages and projects within
in them. An astute reader will observe that 3 of the 4 languages mentioned are
JVM based, so some of my criticisms may not be as relevant in other languages.

First off, what is Mocking in software testing? Like its English counterpart,
a software Mock is an imitation of something, normally an object in
object-orientated programming languages, but you can also create mock
methods/functions. They're mostly used when Unit Testing, to use instead of
some unit you are dependent on.

The oft-given example of when a Mock could be used would be for a database.
Instead of having your tests actually connect to a database you supply a mock
that when queried returns some fixed data for testing with.

In theory, this is great. You can test parts of your project locally and fast,
without having to have additional infrastructure stood up. In reality, they
almost always cause your units to be tightly coupled together and become a
nightmare to maintain.

Admittedly, part of the nightmare is how hard it is to use some mocking
frameworks. In JVM languages they lean heavily upon reflection at runtime to
get class and method information and instantiate an object that reflects the
real class (often also creating an underlying instance of the class somewhere).
Reflection is one of those tools in Java (and its descendants) that can be used
to do all sorts of *magic*. And I use the word "magic" on purpose; frameworks
that use reflection often hides a lot of complexity from the user, but bring
with them a lot of potentially esoteric error messages, and the accompanying
head-scratching.

In terms of coupling, it's my experience that people tend to test the wrong
things with Mocks: They test the internal calls within a classes functions,
rather than testing the contract that a classes API sets out. For example, I
have seen many tests where something like the following (contrived) example is
being tested:

```scala
class IntProvider(var uri: URI) {
    def get(): Int = {
        // code to connect to a URI and convert its contents to an
        // integer but this could be any call to an external resource
        ...
    }
}

class Main(
    val providerA: IntProvider,
    val providerB: IntProvider
) {

    // method being tested
    def run(): Try[Int] = Try {
        // this does something with the provided resources
        providerA.get() * providerB.get()
    }

}
```

Wherein, the test does something like:

```scala
val a = mock(classOf[IntProvider])
val b = mock(classOf[IntProvider])

when(a.get()).thenReturn(11)
when(b.get()).thenReturn(7)

val main = new Main(a, b)

val result = main.run()

verify(a).get()
verify(b).get()

result match {
    Success(value) => assert(value == 77)
    Failure(e)     => fail(e)
}
```

This is a contrived example (and not particularly good Scala code), but the
point is, these `verify` steps are actually testing the internal calls that
`run` does.

The mocking actually highlight a glaring issue with the code and how it is
coupled; `IntProvider` should ideally be a trait/interface, so the code looks
more like the following:

```scala
trait Provider<T> {
    def get(): T
}

class IntProvider(var uri: URI) extends Provider[Int] {
    override def get(): Int = {
        // code to connect to a URI and convert its contents to an
        // integer but this could be any call to an external resource
        ...
    }
}

class Main(
    val providerA: Provider[Int],
    val providerB: Provider[Int]
) {

    // method being tested
    def run(): Try[Int] = Try {
        providerA.get() * providerB.get()
    }

}
```

Then, instead of mocking a whole class we can simply implement a "stub" of the
interface/trait in our testing framework:

```scala
class TestProvider(val value: Int) extends Provider[Int] {
    override def get(): Int = value
}

val a = new TestProvider(11)
val b = new TestProvider(7)

val main = new Main(a, b)
val result = main.run()

result match {
    Success(value) => assert(value == 77)
    Failure(e)     => fail(e)
}
```

Essentially, the crux of my argument here is this: if you decouple your units
enough you should be able to **stub** out the parts of your project that talk
to external dependencies and not need to do any advanced "mocking" and
verification that mocking frameworks provide.

To be clear, a "stub" can be considered a kind of "mock", and most frameworks
actually advise that you only ever mock interfaces rather than classes
themselves, but mocking frameworks give you the ability to easily ignore such
advice. Although, they do this for good reason, as it could be seen as a bad
habit to add lots of extra boilerplate interfaces when only a single
implementation of a class would ever exist (I disagree with this, and say more
about it later).

Generally, mocking tends to lead to bad design choices. My above example is
highly contrived, but I can think of more examples I have seen, related to the
age-old example of mocking a database or connection to external resources like
AWS S3. And these examples have led me to the following conclusion; you should
avoid passing in the raw connection and instead isolate it in its own domain,
that is to say, it is bad design to have a class that relies on many services
external to those that you control. It makes it harder to test your own code by
polluting it with access to externalities. When accessing something external to
the program domain you should ideally be wrapping it in code you do control, so
it is easier to test (with stubs) and easier for someone reading your code to
understand. For example, instead of passing in a direct reference to a
database, wrap it in a class you control and provide a convenient API on-top of
that.

```scala

class UserDB(val connection: Connection) {
    
    // Note I am using domain objects for Users rather than raw
    // rows

    def allUsers(): Seq[User] = {...}

    def user(id: Int): Option[User] = {...}

    def putUser(newUser: User): Unit = {...}

}

```

With that, you control the point where you are coupled to the external system,
and if you want to you can convert it into an interface to stub or isolate your
mocking efforts on just those methods you control the contract of.

Now, this does only move the problem of the external dependencies to the edges
of your code. But, it does make it easier to Unit Test since the code you end
up testing is not the calls made to some external library or system but your
own units. If you find yourself needing to test what happens when a bad
connection is passed in, or interrupted, consider it for what it is, an
Integration Test. In those situations you might want to try and use some
mocking frameworks fancy features to simulate an error heading into your system
but isolate it to only the integration point. Better yet, consider using more
appropriate tools for the job like in-memory databases, or containers
containing the real component (or a service level mock like
[localstack](https://localstack.cloud/)). After all, your software tests should
generally be made up of more steps than just Unit Testing:

<img 
    title="You'll likely be doing some variation of these steps"
    alt="A general diagram of testing, showing that automation decreased as you
    go up each level and time taken increases. The levels from left to right
    are: Unit Testing, Smoke Testing, Integration Testing, System Testing and
    User Acceptance Testing."
    src='{{ "assets/testing-stages.svg" | absolute_url }}'
    class='blog-image'
/>

Most software projects in my experience tend to do at least 2 or 3 steps of
testing, even if they aren't codified as a strict process. Unit Testing and
Integration Testing being those I have seen most often.

Smoke Testing is a term I first heard at [IDR
Solutions](https://www.idrsolutions.com), and are similar to Integration tests.
Essentially, your tests gives some known input to the system you are testing
and compares the systems output to a previous run for differences. If it finds
any they are flagged up for review. It lets you see the effect of changes made
to the overall system, so errors in output can be seen as "smoke" with their
causes being the "fire". There is, after all, no smoke without fire.

In an ideal world, us developers would be able to run all tests on our local
machines instantly to verify changes we make don't cause issues. But
unfortunately, we don't live in the ideal world, so we can compromise with
having Unit Tests run fast and later testing stages either run slower locally
or in a CI/CD environment before merging our code with the master copy of a
project.

It feels like Mocking Frameworks are often used to try and plug the gap between
Unit and Integration Testing. And their unintended effect is to make us lazy
when it comes to both. We wind up mocking the database connections rather than
really testing them in integration tests, and fail to decouple units of our
code enough to be easily testable without them.
