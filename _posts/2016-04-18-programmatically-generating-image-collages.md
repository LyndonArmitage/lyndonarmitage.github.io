---
layout: post
title: Programmatically Generating Image Collages
tags: [medium, blog, collage]
---

<p class="message">
This post was originally published on my old blog and
<a href="https://medium.com/@lyndon.armitage/programmatically-generating-image-collages-aa23ecb270ae">
Medium</a>.
</p>

_Note: Because of how Medium handles links to gists all mentioned data examples
are at the bottom of this post._

I created this project over the course of a few days.

The general idea was to automate the creation of picture collages.

## The Inspiration

Previously a work colleague had created a similar project to show off the power
of distributed computing and Hadoop to some curious customers.
Unfortunately the colleague has since left and I was not able to have a look at
the source to their project so had to start from scratch.

The actual code I have written, in its current form, doesn’t actually run using
Hadoop or any other piece of big data technology as the images and scales I was
testing at just about fit within the memory on a single machine.  
I do however have plans on seeing how hard it is to get this project working
with Apache Spark or another big data technology.

## The Algorithms

Creating a collage automatically can be separated into a few distinct tasks:

1. Dividing the target image into sections
2. Categorizing source images
3. Matching the target image sections to source images

Obviously the last one relies on the first 2 being completed, but both of those
steps can be done independently of each other.

### 1. Dividing the target image into sections

This is relatively simple.  
Given a source image like this:

<img title='This is a screenshot from the game Metal Gear Solid V: The Phantom Pain. This and many other screenshots from the game will be used as examples.' alt='Example Screenshot from Metal Gear Solid V' src='{{ "assets/medium/collage/image1.jpg" | absolute_url }}' class='blog-image' >

* Split it up into sections based on the size and aspect ratio of the image.
* Then sample the average colour of this section. This is what we then use for
  scoring the source images in the 3rd step.

Visualized this might look something like this:

<img title='Note how this is almost the equivalent of blurring or down scaling the image' alt='Screenshot split into sections, looks pixalated' src='{{ "assets/medium/collage/image2.png" | absolute_url }}' class='blog-image' >

### 2. Categorizing source images

This step is similar to the last one, but instead of taking an image and
splitting into sections and getting their average colours it takes whole
images and gets their average colours.

Doing this to many images creates what is essentially a palette to use in the
collage.  
More images are obviously better, and keeping them a consistent size or aspect
ratio makes sure they will not be distorted when scaled. For this example I
used a set of approximately 800 pictures.

This step can take quite a while depending on the amount of images being
categorized and their dimensions and would be an excellent candidate for
parallelizing with something like Spark or a MapReduce job.

At the bottom of this post are some examples of images turned into their
average colours (the full output file is 128KB and about 4000 lines long).
The data output by my code also contains some additional parameters such as
their dimensions and locations on disk. This allows me to run this step once
and reuse the results in step 3 over and over again without having to parse all
the source images again.

### 3. Matching the target image sections to source images

With steps 1 and 2 done all you have to do is marry their 2 resulting pieces of
data together and output an image to disk.

In this step you take each of the sections of the target image and find the
closest matching average colour from the source images.

Then you decide on how big you want each of the collage images to be, in the
example below I set them to be 160px by 90px, this worked well as all
the pictures had the same aspect ratio.

Something to be aware of in this step is how big the resulting collage will be
both in terms of dimensions and file size. A really large output may crash the
JVM as it will run out memory. To rectify this you can split the output into
multiple images that can then be stitched together in another step using an
native tool or graphics program like Adobe Photoshop or GIMP.

In my code I added in the ability to write the output of this step to file so
if needed the rendering to an actual image could be done at a later date or by
several different machines at once. A snippet of the example data can be seen
below (the actual output JSON is about 2.5MB), each section of the image is
given an x,y coordinate that maps to the previously shown data format.

The results of this step end up looking something like this (shrunk to 1920px
by 1080px):

<img title='There was a larger version of this image that has not been hosted' alt='Image of the collage' src='{{ "assets/medium/collage/image3.png" | absolute_url }}' class='blog-image' >

## Potential Additions

* Potentially you could also overlay a transparent copy of the original image
  on top of the collage to restore some of the lost details
* You could try using different colour models instead of just RGB for matching
  the colours of the image. CMYK for instance
* You could take more information than just a single average colour from the
  image section. Algorithms for line and shape detection could help produce a
  match closer to the original section of the image.
* You could come up with a mechanic to reduce the repetition of images,
  something as naive as removing them from the pool of potential images to use
  could work although could potentially require a lot more images to use as a
  palette. Alternatively creating a stack (or ringbuffer) for each image with
  an average colour close to the search colour.
* Using a video as the source of images instead of still screenshots.
  This could be achieved through clever use of something like `ffmpeg`.

## Source code

If desired I can make the source code to the project available online.
Currently it is sat in a private BitBucket git repository.  
Be warned however, as previously mentioned it was hacked together of the
course of a few days!

### Example Image Data (JSON)

```json
{
  "sectionsToSummaries" : {
    "(7,7)" : {
      "width" : 1920,
      "height" : 1080,
      "averageRGB" : 2825996,
      "path" : "/screenshots/2015-09-01_00033.jpg"
    },
    "(0,0)" : {
      "width" : 1920,
      "height" : 1080,
      "averageRGB" : 4272160,
      "path" : "/screenshots/2015-09-20_00030.jpg"
    },
    "(1,1)" : {
      "width" : 1920,
      "height" : 1080,
      "averageRGB" : 4272160,
      "path" : "/screenshots/2015-09-20_00030.jpg"
    },
    "(22,22)" : {
      "width" : 1920,
      "height" : 1080,
      "averageRGB" : 2372138,
      "path" : "/screenshots/2015-10-07_00010.jpg"
    },
    "(102,102)" : {
      "width" : 1920,
      "height" : 1080,
      "averageRGB" : 2370092,
      "path" : "/screenshots/2015-09-20_00015.jpg"
    },
    "(74,74)" : {
      "width" : 1920,
      "height" : 1080,
      "averageRGB" : 3219218,
      "path" : "/screenshots/2015-09-24_00023.jpg"
    }
  }
}
```

### Example (JSON)

```json
[ {
  "width" : 1920,
  "height" : 1080,
  "averageRGB" : 1251351,
  "path" : "/screenshots/2015-11-25_00010.jpg"
}, {
  "width" : 1920,
  "height" : 1080,
  "averageRGB" : 1251351,
  "path" : "/screenshots/2015-11-25_00011.jpg"
}, {
  "width" : 1920,
  "height" : 1080,
  "averageRGB" : 1514266,
  "path" : "/screenshots/2015-11-25_00012.jpg"
}, {
  "width" : 1920,
  "height" : 1080,
  "averageRGB" : 1448730,
  "path" : "/screenshots/2015-11-25_00013.jpg"
}, {
  "width" : 1920,
  "height" : 1080,
  "averageRGB" : 1514780,
  "path" : "/screenshots/2015-11-25_00014.jpg"
} ]
```
