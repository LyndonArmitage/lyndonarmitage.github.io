---
layout: post
title: Vertx Config Toml
---
Today I have quickly thrown together a library to add support for TOML to the Vert.x Configuration service.

The repository can be viewed here: 
[https://github.com/LyndonArmitage/vertx-config-toml](https://github.com/LyndonArmitage/vertx-config-toml)

I did this after reading 2 blog posts on both YAML and JSON being not so great as configuration file 
format solutions and then looking at some of the applications I was working on using JSON as a configuration
format. 
The 2 blog posts in question were by Martin Tournoij (arp242), the first about 
[JSON](https://arp242.net/weblog/json_as_configuration_files-_please_dont)
and the second about [YAML](https://arp242.net/weblog/yaml_probably_not_so_great_after_all.html).
Both were written in 2016 but the YAML one has become popular on 
[Reddit](https://www.reddit.com/r/programming/comments/8shzcu/yaml_probably_not_so_great_after_all/) this week.
