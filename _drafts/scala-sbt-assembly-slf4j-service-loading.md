---
layout: post
title: Scala sbt-assembly & SLF4J Service Loading
tags:
- scala
- sbt
- code
- lambda
- aws
- logging
- slf4j
---

**This was an issue I caused**

Recently I ran into a `No SLF4J providers were found.` logging issue when
building an standalone JAR file (also known as an uber-JAR or fat-JAR) for a
Scala 3 project that was being deployed as an AWS Lambda. This issue revealed a
rabbit-hole related to Java Modules and the `ServiceLoader` system therein.

The full error message that reared it's head only on deployment to Amazon
Lambda was:

```txt
SLF4J(W): No SLF4J providers were found.
SLF4J(W): Defaulting to no-operation (NOP) logger implementation
SLF4J(W): See https://www.slf4j.org/codes.html#noProviders for further details.
```

This suggests that there were no SLF4J providers on the class path. SLF4J is a
logging facade library that provides a nice standard logging API while
abstracting away the actual logging implementation from the user. This allows
your code to use one of many kinds of logging frameworks under the hood, be
they LOG4J, Logback, or even the Java standard library logging framework.

In the case of this project, I opted to use the Logback framework, mostly out
of familiarly with its configuration.

The following is a relevant snippet of my `build.sbt` file defining the
logging dependencies:

```scala
// Logging Libraries
"org.slf4j" % "slf4j-api" % "2.0.11",
"ch.qos.logback" % "logback-core" % "1.4.14",
"ch.qos.logback" % "logback-classic" % "1.4.14",
```

As a side note, if you are using Java 8 you must use Logback versions 1.3.x as
Logback 1.4+ requires Java 11.

During my testing of this project I saw the log message appear in my console,
both when developing in IntelliJ and in NeoVim using Metals. However, when
building and deploying the assembled JAR file using the sbt-assembly plugin I
ran into the dreaded `No SLF4J providers were found.` error message.

Having experienced issues before with shaded and assembled/uber JAR files when
using Apache Maven, my first stop was to check that the assembled JAR file
actually contained the Logback classes within it. Thankfully, JAR files are
just standard zip files with a little bit of extra magic so a quick search with
`zipinfo target/scala-3.2.2/project.jar | grep logback` revealed that all the
expected class files were in fact within the constructed JAR.

My sbt-assembly plugin had the following settings:

```scala
lazy val assemblySettings: Seq[Def.SettingsDefinition] = Seq(
  assembly / test := {},
  assembly / assemblyMergeStrategy := {
    case PathList("log4j.properties")      => MergeStrategy.discard
    case PathList("/org/apache/log4j", _*) => MergeStrategy.discard
    case PathList("META-INF", _*)          => MergeStrategy.discard

    case PathList("META-INF", "io.netty.versions.properties") =>
      MergeStrategy.first

    // Not used in Java 8
    case PathList("module-info.class")               => MergeStrategy.discard
    case path if path.endsWith("/module-info.class") => MergeStrategy.discard

    case x if Assembly.isConfigFile(x) => MergeStrategy.concat
    case x =>
      val oldStrategy = (assembly / assemblyMergeStrategy).value
      oldStrategy(x)
  },
  assembly / assemblyJarName := s"${name.value}.jar"
)
```

You can see that it is set to discard a bunch of files. This is mostly a copy
and paste job from previous Scala 2 projects. The bulk of this is supposed to
discard duplicate files that appear within the JAR file when packaging up all
the dependencies together.

The big issue within these settings that cause SLF4J to topple over are the
lines that discard `module-info.class` files.

To understand why these are causing SLF4J to fail to find the Logback
implementation we need to look at the [SLF4J
documentation](https://www.slf4j.org/faq.html#changesInVersion200) namely this
part:

> In version 2.0.0, SLF4J has been modularized per
> [JPMS/Jigsaw](http://openjdk.java.net/projects/jigsaw/spec/) specification.
> The [JPMS module names](https://www.slf4j.org/faq.html#jmpsModuleNames) are
> listed in another FAQ entry.
> 
> More visibly, slf4j-api now relies on the
> [ServiceLoader](https://docs.oracle.com/javase/8/docs/api/java/util/ServiceLoader.html)
> mechanism to find its logging backend. SLF4J 1.7.x and earlier versions
> relied on the static binder mechanism which is no longer honored by slf4j-api
> version 2.0.x. More specifically, when initializing the `LoggerFactory` class
> will no longer search for the `StaticLoggerBinder` class on the class path.
> 
> Instead of "bindings" now `org.slf4j.LoggerFactory` searches for "providers".
> These ship for example with *slf4j-nop-2.0.x.jar*, *slf4j-simple-2.0.x.jar*
> or *slf4j-jdk14-2.0.x.jar*.

This change to using the `ServiceLoader` mechanism instead of searching for a
`StaticLoggerBinder` class is a major change between SLF4J version 1 and 2.
Now, instead of using reflection to search the class path for implementations
of its API, SLF4J makes use of Java Modules. Unfortunately, the discard of
`module-info.class` also discards the references to the various SLF4J
implementations.

Naively, you could try just omitting the two lines that perform that discard:

```scala
case PathList("module-info.class")               => MergeStrategy.discard
case path if path.endsWith("/module-info.class") => MergeStrategy.discard
```

But then you may run into errors similar to this from sbt-assembly:

```txt
[error] Deduplicate found different file contents in the following:
[error]   Jar name = logback-classic-1.4.14.jar, jar org = ch.qos.logback, entry target = module-info.class
[error]   Jar name = logback-core-1.4.14.jar, jar org = ch.qos.logback, entry target = module-info.class
[error]   Jar name = jackson-annotations-2.12.7.jar, jar org = com.fasterxml.jackson.core, entry target = module-info.class
[error]   Jar name = jackson-core-2.12.7.jar, jar org = com.fasterxml.jackson.core, entry target = module-info.class
[error]   Jar name = jackson-databind-2.12.7.1.jar, jar org = com.fasterxml.jackson.core, entry target = module-info.class
[error]   Jar name = jackson-dataformat-cbor-2.12.6.jar, jar org = com.fasterxml.jackson.dataformat, entry target = module-info.class
```

This is actually the original reason those lines exist: multiple libraries that
are being packaged together in the assembled JAR file have `module-info.class`
entries.

Some searching online regarding these issues returns this still [open
ticket](https://github.com/sbt/sbt-assembly/issues/391) (as of Feb 2024) from
2020 on the sbt-assembly GitHub. The advice within is mainly focussed around
using the discard strategy to avoid the duplicate error message.

So what are the options to fix the `No SLF4J providers were found.` error when
building an assembled JAR with sbt-assembly?

1. You could downgrade to SLF4J 1.7. This side-steps the issue with
   `module-info.class`, as that version of SLF4J still uses the
   `StaticLoggerBinder` method for finding implementations. While this branch
   of SLF4J hasn't been updated since 2022, its API has not changed and SLF4J
   is only a logging facade rather than a full blown library, so there is
   unlikely to be some kind of security issue present.
2. You could try to come up with an advanced merging strategy for
   `module-info.class`. sbt-assembly provides a CustomMergeStrategy class that
   lets you define a merge strategy using a function with the signature
   `Vector[Dependency] => Either[String, Vector[JarEntry]]`.
3. You could bypass the issue and specifically set which SLF4J provider to use
   with the `slf4j.provider` system property.

Out of these 3 options the latter is by far the easiest to implement. All it
requires is setting a property like so
`-Dslf4j.provider=class.of.implementation` when executing the assembled JAR on
the command line, and similarly setting a [custom
option](https://docs.aws.amazon.com/lambda/latest/dg/java-customization.html)
when deploying to AWS lambda. However, it does require you to remember to do
this with your deployment, or alternatively you can try to set this Java system
property during runtime, if you can guarantee your call to `System.setProperty`
will execute before any calls to the SLF4J `LoggerFactory` class.
