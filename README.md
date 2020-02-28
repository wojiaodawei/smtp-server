# Implementation of a MTA (Mail Transfer Agent)

~~ *This project was implemented in December 2015* ~~

**nc** is used to program the mini server and the project is coded in bash, by respecting the RFC 5321 standard.

The server allows, through a classic mail client, to send a mail that can then be read from a pop3 or imap client.

Sent mails are stored in the */home/username/Maildir* directory or in the file */var/mail/username* so that it can be read by a server pop for example.
  

To launch the server, assign first the execute permission to .sh files and execute the bash script: 
```
./server.sh
```
Then, open another terminal in the same directory and execute on port 4567: 
```
telnet localhost 4567
```

To ensure that the server only allows authenticated users to send emails, add password support by adding to *./serveur.sh*:
```
-pass login_pass.txt
```
Authenticated users are those whose login and password are in the *login_pass.txt* file.


To test the server, you can either use the telnet command by writing directly SMTP, or a mail manager such as Thunderbird.


The SMTP server only accepts email addresses of type: *username@condaminet.tp.info.unicaen.fr* and currently allows to manage mails to the *tpmail.info.unicaen.fr* domain.
**This part can be easily modified or deleted within the code.**
