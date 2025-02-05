---
layout: post
title: DeepSeek Scaremongering
tags:
- ai
- llm
- deepseek
- openai
- chatgpt
- open source
- employplan
---

Recently I stumbled upon a post about the Chinese backed Large Language Model
[DeepSeek](https://www.deepseek.com/) on LinkedIn that I wanted to address.
Specifically the post was scaremongering about security concerns with wide
adoption and use of the DeepSeek model.

<img
  alt='DeepSeek Logo'
  src='{{ "assets/deepseek/DeepSeek_logo.svg" | absolute_url }}'
  class='blog-image'
/>

The
[post](https://www.linkedin.com/posts/roch-mamenas-4714a979_deepseek-as-a-trojan-horse-threat-deepseek-activity-7288965743507894272-xvNq?utm_source=share&utm_medium=member_desktop)
looks as followed:

<iframe src="https://www.linkedin.com/embed/feed/update/urn:li:share:7288965741721059329" height="1516" width="504" frameborder="0" allowfullscreen="" title="Embedded post">
<noscript>
> DeepSeek as a Trojan Horse Threat.
> 
> DeepSeek, a Chinese-developed AI model, is rapidly being installed into
> productive software systems worldwide. Its capabilities are
> impressive—hyper-advanced data analysis, seamless integration, and an almost
> laughably low price. 
> 
> But here’s the problem: nothing this cheap comes without a hidden agenda.
> 
> What’s the real cost of DeepSeek?
> 
> \1. Suspiciously Cheap
> 
> Advanced models like DeepSeek aren’t "side projects." They take massive
> investments, resources, and expertise to develop. If it’s being offered at a
> fraction of its value, ask yourself—who’s really paying for it?
> 
> \2. Backdoors Everywhere 
> 
> DeepSeek’s origin raises alarm bells. The more systems it infiltrates, the more
> it becomes a potential vector for mass compromise. Think backdoors, data
> exfiltration, and remote access at scale—hidden vulnerabilities deliberately
> built in.
> 
> \3. Wide Adoption = Global Risk 
> 
> From finance to healthcare, DeepSeek is being installed across critical systems
> at an alarming rate. If adoption continues unchecked, 80% of our systems could
> soon be compromised.
> 
> \4. The Trojan Horse Effect 
> 
> DeepSeek is a textbook example of a Trojan horse strategy: lure organizations
> with a cheap, powerful tool, infiltrate their systems, and quietly map or
> control them. Once embedded, reversing the damage will be nearly impossible.
> 
> The Fairytale Isn’t Real
> 
> The story of DeepSeek being a "low-cost, side project" is just that—a
> fairytale. Technology like this isn’t developed without strategic motives. In
> the world of cyber warfare, cheap tools often come at the highest cost.
> 
> What Can We Do?
> 
> Audit your systems: Is DeepSeek already embedded in your critical
> infrastructure?
> 
> Ask the hard questions: Why is this so cheap? Where’s the transparency?
> 
> Take immediate action: Limit adoption before it’s too late.
> 
> The price may look attractive, but the real cost could be our collective
> security. Don’t fall for the fairytale.
</noscript>
</iframe>

As you can see, it's quite an alarming and inflammatory post, espousing the
threat that DeepSeek poses to businesses everywhere.

Although, when you dig into it, it's not actually saying much. In fact if I
ask ChatGPT4o to:

> Reduce the following post down to the points it actually makes, without
> repetition or commenting on the actual points being made:

It responds with a very short summary of the actual contents:

> 1. DeepSeek is suspiciously cheap, which suggests hidden motives behind its
>    pricing.
> 2. It may contain backdoors, posing a security threat as it integrates into
>    more systems.
> 3. Rapid adoption of DeepSeek in critical sectors could lead to global
>    security risks.
> 4. The model can be seen as a Trojan horse, offering low cost and high
>    capability while potentially compromising systems.
> 5. The narrative of DeepSeek as a low-cost project is misleading, suggesting
>    strategic agendas.
> 6. Organizations should audit systems for DeepSeek's presence, question its
>    pricing, and limit its adoption.

So onto my response to this post.

## Who said it?

First off let's consider who posted it so we can properly attribute it and
check for any biases.

This post was posted by the Chief Technology Officer of
[EmployPlan](https://employplan.com/), [Roch
Mamenas](https://www.linkedin.com/in/roch-mamenas-4714a979/).

EmployPlan appear to be a [small
business](https://www.linkedin.com/company/employplan/) that provides a
"Resource Management Platform", for getting people with the right skills
working on the right project and plugging gaps in skills with training. I've no
idea how successful it is at this, but given Mr Mamenas has run it as CTO and a
founder for 5 years I expect it does alright. I do take a little offence to
calling people "resources" but that's pretty standard and less silly than
saying "bums in seats".

With their business being connecting people with businesses, there may be some
biases around overpowered AI taking jobs away from the ~~people~~ resources
EmployPlan wants to connect you with. After all, why hire people when you can
get a machine to do it? I am being facetious here, as I am a strong believer
that LLMs can't replace actual skilled developers, but it could be a concern of
theirs, especially if LLMs replace a lot of Junior Developers.

There may also be concerns around businesses (even one-man shops) using cheaper
LLMs themselves to screen candidates rather than use a product like EmployPlan.

<img
  title='Turbocharge your IT agency with AI-powered Automation Superpower'
  alt='Turbocharge your IT agency with AI-powered Automation Superpower'
  src='{{ "assets/deepseek/banner-fs8.png" | absolute_url }}'
  class='blog-image'
/>

From the banner on his LinkedIn profile, it seems that EmployPlan is using some
kind of "AI-powered" technology in their product. What this means is anyone's
guess, AI is such a buzzword these days. It could mean something as simple as
"a bunch of if statements" or using full-blown machine learning models. I'll
give the benefit of the doubt and assume actual AI is involved, in fact I'd
assume more traditional AI is actually used alongside the current buzzword
applications.

The mention of being vaguely "AI-powered" is a little red-flag to me that he
may have some vested interests in the AI space. Although, it could equally mean
he is invested in the space so has some righteous concerns around DeepSeek.

From his job history, Mamenas has worked in IT for quite some time, going from
the service desk to bounding between Software Engineer and Analyst for about 6
years before becoming a Chief Architect for 2 and half years before focussing
on startups. Point is, at a glance he doesn't appear to be a poseur with a
cursory understanding of technology.

The post could also be largely inflammatory to motivate discussion, raise his
profile and drive some traffic towards his product. I think the younger
generations call this ["clout
chasing"](https://www.urbandictionary.com/define.php?term=clout%20chasing).

## Addressing the points

With the potential biases and motivations of the author understood, let's dig
into the content of the actual post.

First off, there is a lack of evidence for any of the points Mamenas puts
forward.

So far DeepSeek doesn't appear to have any backdoors in it's code, given that
it is [Open-Source](https://github.com/deepseek-ai) we can verify this and fix
any issues when they appear.

Obviously, we **cannot** guarantee that their live service application is
secure. But the same can be said for any of the LLMs as a service products that
exist, and any SaSS product in general. This is actually one of the ongoing
issues related to the Tik-Tok ban in the US, a proposed solution being to sell
the American arm of the business to a US based company to avoid potential
issues with foreign powers getting their hands on sensitive data (of course
that wouldn't prevent US spying).

I agree with the point that "Wide Adoption = Global Risk", but this point can
be said of any software-as-a-service platform. Putting all your eggs in one
basket is inherently risky. I also like the "80%" stat that comes seemingly out
of nowhere. As we know 73.6% of all statistics are made up.

The fact DeepSeek have Open-Sourced their model means that, if you are
suspicious of them, you can run it yourself on your own hardware. Which
eliminates the risk of "backdoors" or other leaks to the Chinese state.
Obviously this can be cost prohibitive for smaller businesses.

There is risk when it comes to built-in biases within the model. Again, these
exist in all other commercial models. For instance, DeepSeek might not like
speaking ill of the Chinese Government or could have omitted training data
related to June 4th 1989, in fact a commenter on the post points out an
example of DeepSeek's [biased
answers](https://www.linkedin.com/feed/update/urn:li:activity:7288965743507894272?commentUrn=urn%3Ali%3Acomment%3A%28activity%3A7288965743507894272%2C7290117409930162176%29&dashCommentUrn=urn%3Ali%3Afsd_comment%3A%287290117409930162176%2Curn%3Ali%3Aactivity%3A7288965743507894272%29).
Equally, models like OpenAI have developed their own biases based on training
material, whether by design or accident.

The point labeled "Trojan Horse Effect" is an interesting one, but it applies
equally to all software adoption. Microsoft were very good at offering their
products cheaply to schools and universities, which ultimately led to their
wide adoption due to familiarity. Now they're one of the largest movers in the
desktop space, and have effectively captured a large amount of the market. I do
think when it comes to LLMs we're still in the bubble phase, OpenAI have the
first-mover advantage but I expect the most widely adopted LLM service will be
one that hasn't been created yet.

The post keeps circling back on DeepSeek's price point being a red-flag for
concern, but is it really? As the landscape advances, LLMs are going to evolve
to be better than their predecessors in certain dimensions. As an example, I
noticed a big difference between the OpenAI models as they advanced, especially
when it came to understanding source code, and other models are supposed to be
even better than OpenAI. One of the dimensions that is beneficial for all LLMs
to optimise for is obviously running costs, especially for service based
businesses.

The assumption that low-cost = malicious intent, isn't without merit though,
depending on what you consider "malicious". As I mentioned previously,
Microsoft used a similar tactic to penetrate markets and drive widespread
adoption. Large businesses operate at economies of scale that allow them to
undercut competitors. Start-ups with a lot of initial funding can equally
undercut established businesses to bootstrap themselves to success, or disrupt
an industry with novel approaches, or downright ignoring established
legislation like ride-sharing apps did with taxi companies.

We also mustn't forget the effect from "standing on the shoulders of giants",
advancements happen thanks to the work done previously. Normally, this is a
slow incremental process, but occasionally we see jumps in human understanding
and knowledge.

Sometimes it is wiser to use the more expensive option or to use a homegrown
alternative to a foreign business. As the debacles related to shortages of
personal protective equipment and drugs taught us during the pandemic. Global
supply-chains are susceptible to disruption and that disruption can be even
easier in the digital space.

Out of interest I asked DeekSeek's uncle, ChatGPT4o, to give me some potential
criticisms of this post:

> 1. **Lack of Evidence**: The post raises concerns about DeepSeek’s security
>    implications, but it does not provide concrete evidence or examples of
>    security breaches or backdoors attributed to DeepSeek.
> 
> 2. **Assumptive Reasoning**: The post assumes that low cost necessarily
>    implies malicious intent, which may not always be the case. There could be
>    other reasons for the low pricing, such as market penetration strategies.
> 
> 3. **Fearmongering**: By using terms like "Trojan horse" and suggesting
>    large-scale compromise without backing data, the post may be seen as
>    fearmongering, potentially causing unwarranted panic among users.
> 
> 4. **Generalization**: The claim about global risk from widespread adoption
>    does not consider differing degrees of security measures across industries
>    or specific usage contexts.
> 
> 5. **Lack of Alternatives or Solutions**: While the post suggests auditing
>    and questioning DeepSeek’s pricing, it lacks a deeper exploration of
>    alternatives for users who might find value in DeepSeek’s capabilities.
> 
> 6. **Xenophobia**: Highlighting DeepSeek's Chinese origins as inherently
>    threatening might come across as xenophobic, attributing risk based purely
>    on national origin rather than objective analysis of the technology.
> 
> 7. **Ignorance of Open Source or Unconventional Funding**: The post does not
>    consider the possibilities that DeepSeek could benefit from open source
>    contributions or alternative funding models that allow for lower pricing. 
> 
> Ensuring claims are substantiated, examining motivations thoroughly, and
> providing balanced viewpoints are critical for a fair assessment.

Admittedly, it gives a bit of milquetoast answer, not uncommon with LLMs.

ChatGPT did raise an excellent point on ignoring usage contexts. Just because
something becomes widespread doesn't mean it allows total domination, it's all
context dependent. Obviously if you plug an LLM into your infrastructure, give
it free rein to access all your data and systems, you're asking for trouble.
But with controls in place it's a much smaller issue. If you never supply it
with sensitive information then even if it leaks that information it's a
non-issue.

With all that said, I agree with the conclusion about auditing your systems,
but I'd make a modification to it:

> Audit your systems: Risk-assess what is embedded in your critical 
> infrastructure?

Be it AWS, OpenAI, DeepSeek, Oracle SQL Server, or any other solution. You need
to know where your risk points are, where you've committed to a one-way door
decision (one not easily reversed), and what mitigations you have in place (if
any). There's a reason that we often uses interfaces or APIs in software
development; to insulate ourselves from change.

After evaluating all these points you might find that the risks are minimal or
that they outweigh the possible gains.
