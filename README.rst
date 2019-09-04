=========================================
mw(1) Version 1.0 \| mutt-wizard man page
=========================================

..   To test man page:
..
..     pandoc README.rst -s -t man | /usr/bin/man -l -
..
..   The generate:
..
..     pandoc README.rst -s -t man -o mw.1


NAME
====

**mw** — mutt-wizard - add, list, remove email configurations for mbsync, getmail and mutt. Sync email without mutt.

SYNOPSIS
========

**mw** [<command>|<email>]

| **mw**  Same as *mw sync*
| **mw add**  Add and configure an email address (9 max.)
| **mw list**  List configured accounts
| **mw remove**  Pick an account to remove
| **mw purge**  Remove all accounts and settings
| **mw cron**  Enable or disable an autosync via cronjob
| **mw sync**  Sync mail based on config in *.config/isync/mbsyncrc* and *.config/getmail/\**
| **mw –help\|-h**  Print this message
| **mw –version\|-v**  Print version

DESCRIPTION
===========

**mw** configures **mbsync**, **getmail**, **msmtp** and **mutt** in one go.
**mutt** stands for **mutt** or **neomutt**.

COMMANDS
========

Without command parameter **sync** is assumed.
If the parameter contains @ an email is assumed and synced.

*add*

    Add new email.

    - First you decide, whether you want to configure
       - **mbsync**, **getmail**, **msmtp** to sync emails independently from **mutt** using **mw**,
       - or just **mutt**. 
         For an IMAP server **mutt** becomes very slow.
         So normally you enter **yes** here.
    - **mw** asks you the **email address**.
    - **mw** has a **database** of IMAP4/POP3 and SMTP servers and ports.
      If you are lucky, your email server is there.
      Else **mw** will prompt you.

*ls|list*

    List all email accounts configured by mutt-wizard

*rm|remove*

    Remove the configuration files for an already configured email

*purge*

    Removes all mw generated mutt settings and

    | *.config/mutt/accounts/1-\**
    | *.config/isync/mbsyncrc*
    | *.config/getmail/\**
    | *.config/msmtp/config*

    Files are under *.config* or *$XDG_CONFIG_HOME*.

*cron*

    Toggle a cronjob that periodically syncs mail

*sync*

    Syncs mail for all email accounts managed by **mw** (whose paths end in the email).
    This is the default, if no parameter is given.
    If an email address is given, only that email is synced.

    - Every **mw** sync run will re-generate the **mutt** configuration
      from the configuration files for **mbsync**, **getmail** and **msmtp**.
      So you could edit them after or not use *mw add* at all.

      Just keep the *Path*, *path* and *account* ending in the email address.

    - The generated **mutt** configuration has these bindings

    - */usr/share/mutt-wizard/mutt-wizard.muttrc* is linked in your *muttrc*.
      Have this line there, if you prefer your own settings::

        # source /usr/share/mutt-wizard/mutt-wizard.muttrc

      You will need to keep the binding of *i,g,C,M* to *noop*, though,
      because of the generated bindings in the account muttrc.

DEPENDENCIES
============

- *pass* - `pass <https://www.passwordstore.org/>`__ safely encrypts passwords (**required for email setup**)
- *gnupg* - needed by *pass*
- *mutt/neomutt* - the email client (*mutt* untested).
- *isync’s mbsync* - syncs the mail
- *getmail* - used for POP3
- *msmtp* - sends the email

Optional:

- *w3m* - view HTML email and images in **mutt**.

- *notmuch* - index and search mail.
  If the configuration file *$NOTMUCH_CONFIG* is not there,
  *mw add* will create it.

- *libnotify* - allows notifications when syncing mail with **mw**

- *abook* - a terminal-based address book.

- A cron manager (e.g. *cronie*) - if you want to enable the auto-sync
  feature.

- *pam-gnupg* - To provide your GPG key at login and never after.
  See `directions <https://github.com/cruegge/pam-gnupg>`__.

  Alternatively avoid constant password requests by increasing

  - *default-cache-ttl* and *max-cache-ttl* in *gpg-agent.conf*

- *urlscan* - outputs urls in mail

INSTALLATION
============

::

   git clone https://github.com/rpuntaie/mutt-wizard
   cd mutt-wizard
   sudo make install

MUTT CONFIGURATION
==================

Once everything is setup, you’ll use **mutt** to access your mail.

The accompanied */usr/share/mutt-wizard.muttrc* modifies some **mutt** defaults.
Look there for a complete list.

Here an overview:

- *?* - see all keyboard shortcuts

**syncing**

- *gm / gM* - call mutt-wizard’s *mw sync* for one / all mail accounts

**mailboxes,accounts**

- *ixy* - To go to **mailbox**.
- *Mxy*, *Cxy* - For Move and Copy to the according mailbox,
  e.g. *Msp* means "move to Spam".
- *i[1-9]* - go to another **account**.

  *xy* are

  - the two first letters of a mailbox or
  - first letter of first + second letter of second path entry

**searching**

- *S* - search for a mail using *notmuch*
- *gl* - limit by substring of subject
- *gL* - undo limit

**composing**

- *ga* - to add address/person to *abook* and *Tab* while typing
  address to complete one from book.
- *m/r/gr/f* - new/reply/group reply/forward **message**,
  using your default *$EDITOR* to write.
  Then you enter the **compose screen**.
- *a* - to add attachments
- *s/t/c/b/d* - to change the subject/to/CC/BCC/description.
- *S* - to change the signature/encryption
- *y* - to send the mail.

**delete,undelete,save**

- *dd* - delete mail
- *u* - undelete
- *$* - apply the mailbox changes *set trash* is set per default.
  Deleted mails will land there.
- *s* - save selected mail or selected attachment

**moving around**

- *gu* - open a menu to select a url you want to open in you browser
  (needs urlscan).
- *j*/*k* - next/previous mail, *J/K* same, without skipping deleted,
  and also when viewing mails
- *ctrl-d/f*/*ctrl-u/b* - down and up a half page / full page
- *l* - open mail, or attachment page or attachment
- *h* - the opposite of *l*

**sidebar**

- *B* - toggles
- *ctrl-j*/*ctrl-k* - move up and down
- *ctrl-l/o* - opens mailbox

**input field/command line**

- *ctrl-u* clears the line
- *ctrl-a*, *ctrl-e* go to beginning or end
- *ctrl-g* aborts

DETAILS
=======

**Encoding/Language**

    *isync* is not fully UTF-8 compatible.
    **mw** assumes english mailbox names.
    Set your email language to English on your mail server.

**Mail location**

    Mail is downloaded to a folders named after your emails in *$MAILDIR*.
    *$MAILDIR* defaults to *$HOME/Mail/*.
    Neither **mw remove** nor **mw purge** will delete downloaded mail.

**Gmail accounts**

    For Gmail allow "less-secure" applications:
    <https://support.google.com/accounts/answer/6010255>.
    Do this before running mutt-wizard.

**Protonmail accounts**

    Protonmail users must use the Protonmail Bridge
    <https://protonmail.com/bridge/>
    to access their IMAP and SMTP servers.
    Do this before running mutt-wizard.

FILES
=====

*/user/bin/mw*
   The main script to manage and sync emails.

*/user/bin/mwimage*, */user/bin/mwopen*
   Used by the mailcap file that comes with mutt-wizard.

*/usr/share/mutt-wizard/mutt-wizard.muttrc*
   Default mutt settings.

*/usr/share/mutt-wizard/mailcap*
   Default mailcap file.

*/usr/share/mutt-wizard/domains.csv*
   Email server database.

BUGS
====

GitHub Issues: <https://github.com/rpuntaie/mutt-wizard/issues>

AUTHORS
=======

*Luke Smith* <luke@lukesmith.xyz>
   Original author, started in 2018.

   Github <https://github.com/lukesmithxyz/mutt-wizard>

   Gitlab <https://gitlab.com/lukesmithxyz/mutt-wizard>

*Roland Puntaier* <roland.puntaier@gmail.com>
   Bugfixes, Improvements in 2019.

   GitHub: <https://github.com/rpuntaie/mutt-wizard>

LICENSE
=======

GPLv3

SEE ALSO
========

**neomutt**\ (1), **neomuttrc**\ (1) **mbsync**\ (1), **msmtp**\ (1),
**notmuch**\ (1), **abook**\ (1)
