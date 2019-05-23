---
layout: page
title: Contact
---

I can be contacted in the following places:

* [LinkedIn](https://www.linkedin.com/in/lyndonarmitage/)
* [Twitter: @LyndonArmitage](https://twitter.com/LyndonArmitage)

<p id="email-text">
You can also <a id="email">email</a> me.
</p>

<noscript>
In order to see my email address please enable JavaScript.
This is to prevent nasty web scrapers from harvesting my email address.
</noscript>

<script>

(function () {
  
  // This is a very simple substitution cipher to stop scraping bots that 
  // look for emails from finding my email address
  var input  = "abcdefghijklmnopqrstuvwxyz.@+:";
  var output = ":+.@xyzuvwrstopqlmnijkfghcdeab";
  function mapText(text, input, output) {
    var encrypted = text;
    var index = x => input.indexOf(x);
    var translate = x => index(x) > -1 ? output[index(x)] : x;
    return text.split('').map(translate).join('');
  }

  var isBot = /bot|google|baidu|bing|msn|duckduckbot|teoma|slurp|yandex/i
      .test(navigator.userAgent)
  var element = document.getElementById("email");
  if (!isBot) {
    var email = "t:vsipbsho@pod:mtvi:zxa.poi:.iezt:vsd.pt";
    var translated = mapText(email, output, input);
    element.setAttribute(
      "href", 
      translated
    );
  } else {
    // delete the email section for known bots
    element.parentElement.innerText = "You have been detected as a bot, but a real user can see my email address here.";
  }
})();
</script>
