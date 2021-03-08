window.addEventListener( "load", function() {
  const form = document.getElementById("commentForm");
  if (!form) return;

  function setFormState(disabled) {
    const f = form.getElementsByTagName("input");
    for (var i=0; i < f.length; i++) {
      f[i].disabled = disabled;
    }
    document.getElementById("commentText").disabled = disabled;
    document.getElementById("submitComment").disabled = disabled;
  }

  // https://stackoverflow.com/a/38931547/1590490
  function urlencodeFormData(fd) {
    var params = new URLSearchParams();
    for(var pair of fd.entries()) {
        typeof pair[1]=='string' && params.append(pair[0], pair[1]);
    }
    return params.toString();
  }

  function sendForm() {
    const formData = new FormData(form);
    const XHR = new XMLHttpRequest();

    XHR.addEventListener("load", function(event) {
      console.log("Comment submitted succesfully");
      const response = JSON.parse(event.target.responseText);
      console.log(response);
      if(response.success) {
        alert("Comment submitted succesfully, please wait for it to be moderated");
        setFormState(true);
      } else {
        alert("There was a problem with your comment: " + response.errorCode);
        setFormState(false);
      }
    });

    XHR.addEventListener("error", function(event) {
      console.log("Problem with comment:");
      console.log(event);
      setFormState(false);
      alert("There was a problem submitting your comment, please try again later.");
    });

    const encoded = urlencodeFormData(formData);
    XHR.open( "POST", form.action );
    XHR.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
    XHR.send(encoded);
    setFormState(true);
  }

  
  form.addEventListener( "submit", function ( event ) {
    event.preventDefault();
    sendForm();
  });

});
