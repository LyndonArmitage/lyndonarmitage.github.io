---
layout: post
title: A Paranoid Home Network
tags:
- security
- home
- networking
date: 2021-05-20 09:45 +0100
---
Digging through some old notes I stumbled upon the diagram I made when planning
my home network during my last move. I had decided to take a little paranoid
approach to my networking.

<img alt='Home Network Diagram' title='Home Network  Diagram' src='{{ "assets/home-network-diagram.png" | absolute_url }}' class='blog-image' >

First I divided my devices into groups based on how much I trusted them.  
I had:

* The router/modem provided by my ISP (Vodafone at the time)
* My own WiFi router
* My phone
* My Desktop
* A Raspberry Pi
* Work Laptop
* My TV
* An Alexa

I also accounted for any guest's mobile phones.

The groups of trust I settled on were based on the potential risks I perceived
from my devices based on them running code I was not privy too. Of course
basically all devices do this to some extent or other but those I labeled
"Untrusted" in my diagram were the ones that were almost entirely black boxes
to me.

From there I decided to separate the WiFi networks and access these groups had.  
My ISP related stuff sat in it's own zone, the guests and other "Untrusted"
devices were grouped in their own zone, and finally my trusted devices sat in
theirs.

There were and are some potential issues with my setup:

* Mobile phones are notorious for calling home and running unknown code so I
    could in theory keep my phone in the "Untrusted" group, however I like to
    be able to connect to my devices from it.
* The WiFi router I own dials home. This is basically unavoidable, I have toyed
    with blocking the domain from the ISP router however, that is one of the
    benefits of separating your router from your modem.
* I have to port forward on both the ISP router and my WiFi router if I want to
    expose a port to the outside world.

Overall however it has worked pretty well for the last several years. I even
keep the WiFi network for the trusted devices hidden somewhat by not having it
broadcast an SSID. I can have a slightly easier password for the "Untrusted"
network for people to key into devices (still long but with less annoying
symbols).
