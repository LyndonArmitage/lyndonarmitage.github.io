---
layout: post
title: Migrating from offlineimap to isync
tags:
- linux
- email
- command line
- terminal
- offlineimap
- isync
- degoogle
- mutt
date: 2021-03-24 17:30 +0000
---
Recently I have been experimenting with the terminal email client
[mutt](http://www.mutt.org/) ([neomutt](https://neomutt.org/) to be specific)
in preparation for setting up my own email server (I want to stop being over
reliant on GMail).  
Initially I stumbled upon [offlineimap](https://www.offlineimap.org/) as a way
of downloading and syncing mail from an IMAP server, but as it turns out it is
built in Python 2 and considered a bit obsolete and slow by many.
So after some searching I discovered [isync](https://isync.sourceforge.io/) as
a suitable replacement and decided to migrate to it from `offlineimap`, a
process I will document below.

To start with you need to be aware that `isync` is the name of the application
but the binary provided is called `mbsync`.

My `offlineimap` config looked something like:

```ini
[general]
pythonfile = ~/.offlineimap.py
accounts = mail
starttls = yes
ssl = yes

[Account mail]
localrepository = mail-local
remoterepository = mail-remote

[Repository mail-remote]
type = IMAP
remotehost = mail.server.com
remoteuser = lyndon@server.com
remotepasseval = get_pass("personal/email/lyndon")
sslcacertfile = /etc/ssl/certs/ca-certificates.crt

[Repository mail-local]
type = Maildir
localfolders = ~/.Mail/mail
```

In `offlineimap` you have the concept of an Account which is made from 2
Repositories. In my example one is a local Maildir repository and the other is
a remote IMAP repository.

The configuration itself is incredibly simple, and even allows you to evaluate
some code to get your password credentials (I use an application called
`pass`).

`isync`'s configuration is a little different. But the concepts are similar:  
Instead of a Repository the equivalent is called a Store in `isync`
and what was known as an Account in `offlineimap` is called a Channel.  
When dealing with IMAP `isync` allows you to separate the credentials out
into an IMAP Account and refer to them in an IMAP Store, letting you use the
same credentials for multiple Stores.  
The format is not INI like `isync` but instead a more common `rc` style
configuration file:

```rc
# Isync Mail Config

IMAPAccount mail
Host mail.server.com
User lyndon@server.com
PassCmd +"pass personal/email/lyndon | head -1"
Port 993
SSLType IMAPS
SystemCertificates yes

IMAPStore mail-remote
Account mail

MailDirStore mail-local
Path /tmp/maildir/
Inbox /tmp/maildir/INBOX

Channel mail
Far :mail-remote:
Near :mail-local:
Patterns * # This syncs all Mailboxes
Create Near # This creates folders for all remote mailboxes
SyncState *
```

Thankfully this is not that complicated to adapt the previous config too.

Unfortunately I read that many had issues using the same Maildir they used in
`offlineimap` with `isync` so to avoid this issue I decided to delete my
current mail folder and re-synchronize completely.

Then, after creating the folder to store mail in, simply running `mbsync
mail` synchronizes my email! Simple as!

Hopefully this might be useful to somebody who made the same mistake of using
`offlineimap` first before `isync`.
