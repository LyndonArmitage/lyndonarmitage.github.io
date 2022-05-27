---
layout: post
title: Software Activism &amp; NPM
tags:
- opinion
- node
- npm
- javascript
- activism
- software
- politics
- open source
date: 2022-03-18 16:47 +0000
---
Recently there's been an outpouring of software activists or, as some call
them, hacktivists, protesting the war between Russia and Ukraine. One of these
people, a man by the name of
[Brandon Nozaki Miller](https://github.com/RIAEvangelist), decided to introduce
malware into a popular Node.js library known as
[node-ipc](https://github.com/RIAEvangelist/node-ipc).

In brief, node-ipc is a project to perform local and remote inter-process
communication between Node.js software. This allows applications to
communicate between each other using low level transport protocols. The project
has about 5 million monthly downloads.

The Register has an
[article](https://www.theregister.com/2022/03/18/protestware_javascript_node_ipc/)
on this, as does
[snyk](https://snyk.io/blog/peacenotwar-malicious-npm-node-ipc-package-vulnerability/)
who have done an awesome job summarising the events and the code in question.

For a short summary of what the code does:

1. It creates a file on users desktops without permission.
2. If the user's IP is identified as being in Russia or Belarus it recursively
   replaces all files on their machine with heart emojis.

The
[original commit](https://github.com/RIAEvangelist/node-ipc/blob/847047cf7f81ab08352038b2204f0e7633449580/dao/ssl-geospec.js)
that introduced this code has since been removed from active use but has been
de-obfuscated
[here](https://gist.github.com/BrandonMiller97528/671a8bbb8da41ca34b30105db1edde1d)
for easier understanding.

The fact that this code went live and was automatically installed on machines
is worrying. As mentioned in snyk's article, the new functionality is not
documented in the README, and was sneaked into the source code and published
without any announcements. That alone is cause for concern.

Software, especially Open-Source Software, is built upon the idea of trust.
When consuming any kind of software you are entering into an agreement with the
developers of that software. That agreement is that you will abide by the
software's licence, often in the case of open source it is some kind of GPL
licence. And in turn, the software will provide the features it advertises.

Let's approach this with an analogy grounded in the physical world:

I run a small business selling cutlery, specifically metal spoons. My spoons
are relatively popular and used in many different places. I improve upon their
design periodically and release newer ones that customers eagerly upgrade to,
often before their existing ones degrade.

One day, after watching a passionate documentary, I decide that dairy is the
devil. So, without announcing it, I re-engineer my spoons to dye the milk they
touch red. Additionally, I decide that if they're used in the countryside,
where the dairy farms are, they should also cause the bowls they are in to
break.

People buy these new spoons and begin using them. My customers become enraged
as their bowls of cereal are ruined, especially those who happen to live in the
countryside. Were my actions justifiable? Were they sensible? Have I committed
a crime?

Some animal rights protesters might laud my actions, while others condemn them.
People who enjoyed using my cutlery for their breakfast may be annoyed and
choose to use other spoons, or put up with their blood coloured milk. Now
suppose that, after seeing this annoyance, I quickly recall all existing spoons
and release a version without these features. Does this effect the answers to
the above questions?

Like with my spoon analogy, Mr Miller quickly reverted his changes, but not
before many people suffered. One user commented that their NGO monitoring war
crimes in Russia/Belarus suffered
[irreparable harm](https://github.com/IdealismIncinerator/node-ipc/blob/master/README.md#a-major-victim).
To which, Miller's reply is an attempt to absolve himself of guilt.

To be categorically clear, what Brandon Miller did, in my opinion, constitutes
a crime, at least under the [UK's Computer Misuse
Act](https://www.legislation.gov.uk/ukpga/1990/18/section/3) which is worded
similarly to other cyber crime acts around the globe. He knowingly, and
recklessly, introduced malicious code into a project in order to impair or
destroy data on computers he had no authorization to do such to. His
intentions, however noble from his point of view, are irrelevant. Further, he
has eroded the trust in Open Source Software with both his cavalier actions and
refusal to own up to the seriousness of what he has done.

I am far from a fan of what Russia is doing to Ukraine right now, having spent
time there with friends still living in Kyiv. But this is another example of
politics rearing its head into matters where it does not belong. Software
should be completely agnostic to the current political climate, otherwise it
becomes yet another tool in the arena of petty arguments that is politics.
Miller's malware could have caused damage to innocents, both those living in
those countries who oppose the current war, as well as those mistakenly
identified as such, either from using a VPN or through poor GeoIP location
data; meaning it could well have effected people in the border regions of
Ukraine, Poland, Latvia, Lithuania, Estonia, and Finland.

It is also another example of the glaring issues in the JavaScript environment,
already exposed by the [leftpad
fiasco](https://www.theregister.com/2016/03/23/npm_left_pad_chaos/) in 2016.
The JavaScript ecosystem seems to be more prone to these issues than other
programming languages, a troubling situation when you consider what modern
websites run on.

In short, keep politics out of your software projects, fix the damn JavaScript
package management environment, and regardless of your opinion on the current
conflict in Ukraine, take part in less destructive and more legal forms of
activism.
