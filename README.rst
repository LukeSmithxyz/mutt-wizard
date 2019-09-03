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

**mw** — mutt-wizard - add, list, remove email configurations for
mbsync, getmail and mutt. Sync email without mutt.

SYNOPSIS
========

**mw** [<command>|<email>]

| **mw**  Same as *mw sync*
| **mw add**  Add and configure an email address (9 max.)
| **mw list**  List configured accounts
| **mw remove**  Pick an account to remove
| **mw purge**  Remove all accounts and settings
| **mw cron**  Enable or disable an autosync via cronjob
| **mw sync**  Sync mail based on config in *.config/isync/mbsyncrc *  and *.config/getmail/\**
| **mw –help\|-h**  Print this message
| **mw –version\|-v**  Print version

DESCRIPTION
===========

**mw** configures **mbsync**, **getmail**, **msmtp** and **mutt** in one
go, or just **mutt**. Note, **mutt** stands for **mutt** or **neomutt**,
but **mw** settings was only tested with **neomutt**.

COMMANDS
========

Without command parameter **sync** is assumed. If a parameter contains @
an email is assumed and synced.

*add*

    Add new email.

    - First you decide, whether you want to configure
       - **mbsync**, **getmail**, **msmtp** to sync emails independently from **mutt** using **mw**,
       - or just **mutt**. 
         For an IMAP server **mutt** becomes very slow.
         Normally you enter **y**.
    - It asks you the **email address**.
    - It has a **database** of IMAP4/POP3 and SMTP servers and ports.
      If you are lucky, your email server is there.
      Else it will prompt you.

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


    toggle a cronjob that periodically syncs mail

*sync*


    syncs mail for all email accounts managed by *mw* (whose paths end in the email).
    This is the default, if no parameter is given.
    If an email address is given, only that email is synced.

    - Every **mw** sync run will re-generate the **mutt** configuration
      from the configuration files for **mbsync**, **getmail** and **msmtp**.
      So you could edit them after or not use *mw add* at all.

      Just keep the *Path*, *path* and *account* ending in the email address.

    - The generated **mutt** configuration has these bindings
      - *ixy/Mxy/Cxy* bindings to switch/move/copy to mailbox (x and y stand for other letters)
      - *i[1-9]* bindings to switch account

    - */usr/share/mutt-wizard/mutt-wizard.muttrc* is linked in your *muttrc*.
      Have this line there, if you prefer your own settings::

        # source /usr/share/mutt-wizard/mutt-wizard.muttrc

      You will need to keep the binding of *i,g,C,M* to *noop*, though,
      because of the generated bindings in the account muttrc.
      Else you can overwrite certain things after the uncommented sourcing line.

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

- *notmuch* - index and search mail. If the configuration file in
  *$NOTMUCH_CONFIG* is not there, *mw add* will create it.

- *libnotify* - allows notifications when syncing mail with *mw*

- *abook* - a terminal-based address book.

- A cron manager (e.g. *cronie*) - if you want to enable the auto-sync
  feature.

- *pam-gnupg* - To provide your GPG key at login and never after. See
  `directions <https://github.com/cruegge/pam-gnupg>`__.

  Alternatively increasing *default-cache-ttl* and *max-cache-ttl* in
  *gpg-agent.conf* avoid constant password requests.

- *urlscan* - outputs urls in mail

INSTALLATION
============

::

   git clone https://github.com/rpuntaie/mutt-wizard
   cd mutt-wizard
   sudo make install

User of Arch-based distros can also install mutt-wizard from the AUR as
`mw-git <https://aur.archlinux.org/packages/mw-git/>`__.

MUTT-WIZARD'S NEOMUTT CONFIGURATION
===================================

Once everything is setup, you’ll use **mutt** to access your mail.

Mutt usage with the accompanied */usr/share/mutt-wizard.muttrc*:

- *?* - see all keyboard shortcuts

**syncing**

- *gm / gM* - call mutt-wizard’s *mw sync* for one / all mail accounts

**mailboxes,accounts**

- *ixy* - To go to **mailbox**.
- *Mxy*, *Cxy* - For *M*\ ove and *C*\ opy to the according mailbox,
  e.g. \ *Msp* means “move to Spam”.
- *i#* - Press *i* followed by a number 1-9 to go to a **different
  account**.

  *xy* are

  - two first letters of mailbox letters or
  - first letter of first path entry + second letter of second path
    entries

**searching**

- *S* - search for a mail using *notmuch*
- *gl* - limit by substring of subject
- *gL* - undo limit

**composing**

- *ga* - to add address/person to *abook* and *Tab* while typing
  address to complete one from book.
- *m/r/gr/f* - new/reply/group reply/forward **message**, using your
  default *$EDITOR* to write. Then you enter the **compose screen**.
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

- *ctrl-u* will clear it
- *ctrl-a*, *ctrl-e* go to beginning or end, *ctrl-g* aborts

Look into */usr/share/mutt-wizard.muttrc* to see all bindings.

DETAILS
=======

:Encoding:

    *isync* is not fully UTF-8 compatible. Non-Latin characters may be
    garbled (although sync should succeed). *mw* will also not auto-create
    mailbox shortcuts since it is looking for English mailbox names. I
    strongly recommend you to set your email language to English on your
    mail server to avoid these problems.

**Mail location**

    Mail is downloaded to a folder named after your email
    in *\$MAILDIR*, which defaults to *\$HOME/Mail/*, the default for mutt.
    Neither **mw remove** nor **mw purge** will delete downloaded mail.
    Do that manually.

**Gmail accounts**

    Google will require you to allow "less-secure" (third party)
    applications or use two-factor authentication in order to access
    their IMAP servers to download your mail.
    If you use Gmail, be sure to handle this before running mutt-wizard
    <https://support.google.com/accounts/answer/6010255>.

**Protonmail accounts**

    Protonmail users must use the Protonmail Bridge
    <https://protonmail.com/bridge/> to access their IMAP and SMTP
    servers. This too should be configured before running mutt-wizard.

**Enterprise and university accounts**

    Many universities and businesses might host their domain\'s email
    via Google or another service.
    This often requires a special IMAP/SMTP-specific password
    that you must generate and use. Again, mutt-wizard can handle these
    systems, but only once they have been set up.

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

   -  Honors *:math:`MAILDIR*, *`\ XDG_CONFIG_HOME*, *$XDG_CACHE_HOME*,
      if defined.
   -  *gm/gM* to sync mail inside *mutt*, as *o/O* has a *mutt*
      assignment already.
   -  Other more vim-like shortcut changes
   -  Make channel name equal to email address to avoid choosing a new
      name for the same thing.
   -  *remove|rm* instead of *delete*, *list|ls* instead of only *ls*
   -  *wm* integrates *mailsync*, not to overload the system namespace
      and because of code reuse
   -  *wm* generates *mutt* config on every full sync,

      -  to reflect changes in mailboxes in the shortcuts
      -  to reflect changes in *mbsync/getmail* config in *mutt* config

   -  *urlscan* instead of *urlview*
   -  Added tests and made bug fixes
   -  Generate man page from readme, to avoid duplicate descriptions

LICENSE
=======

GPLv3

SEE ALSO
========

**neomutt**\ (1), **neomuttrc**\ (1) **mbsync**\ (1), **msmtp**\ (1),
**notmuch**\ (1), **abook**\ (1)
