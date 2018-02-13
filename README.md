# Luke's mutt Wizard for automatic Neomutt and OfflineIMAP configuration!

![mutt wizard preview](etc/mw.png)

Mutt is one of the most rewarding programs one can use, but can be a pain in the ass to configure. Since my job is making power-user tools available for the masses I want to create a tool that automates most of mutt configuration so that users can simply give their email address and get a /comfy/ setup. At that, I don't just want a mutt wizard, but an offlineIMAP wizard, so users can easily access their mail offline as well, and a wizard that makes it easy to store passwords securely using gpg.

## User interface

The main script can take an email and autodetect its server settings, generating a muttrc and offlineimaprc profile automatically. I gives you options for add accounts to the system, detecting them, removing them and autodetecting mailboxes and generating shortcut keys in mutt. You get:

+ Automatic configuration of mutt and offlineimap
+ Automatic encryption and safe storage of passwords which are used my mutt and offlineimap when necessary
+ Multiple account management in mutt: jump from account to account with the `i` prefix in mutt: `i1`: first email account, `i5`: fifth, etc.
+ Easy movement to mail folders in mutt: `gi`: go to inbox, `gs` to sent mail, `ga` to archive, `gS` to spam, `gd` to drafts, etc.
+ Some sensible default controls and colors. This system is going to be integrated into my [public auto-rice script](https://larbs.xyz) so I want it to look pretty and be usable out the box.

### Will it work on my email? (95% yes)

Yes! At this point, the only problems are the unexpected ones. Please try it, and if you do run into problems, email me at [luke@lukesmith.xyz](mailto:luke@lukesmith.xyz)! I've tried the system personally on Gmail, Teknik.io, cock.li and Yandex, while others have tried other providers. If your domain is in the `domains.csv` configuration should be 100% automatic and error free, if it's not in the file, the prompt will simply ask you for server information which you can look up yourself; the script knows exactly where to put everything and will configure everything else!

The only email provider which I think will *not* work (and will never work) is Proton Mail, but that's only because they require encryption through their web client IIRC.

## Installation and Dependencies

dialog, neomutt and offlineimap should be installed. The contents of this repo should go directly in `~/.config/mutt/` and run from there. You also need to have a GPG public/private key pair for the wizard to automatically store your passwords. Otherwise you'll have to store them insecurely in plaintext files without the help of the wizard.

Just run `mutt-wizard.sh` for all the options.

Once you successfully run the script, you should be able to simply run `offlineimap` to start your mail sync (which will be big at first). Opening `neomutt`, you should see your mail.

Note that once you run `offlineimap`, you'll want to reopen the script and select the option to autodetect mailboxes to put the finishing touches and to let you switch from mailbox-to-mailbox in just two key presses.

### "Wait? The script asks for my passwords?"

Look at the code. The script takes the passwords you give it, encrypts them immediately with your own GPG key, and shreds the leftovers. Nothing malicious; it's all there! If it makes you comfortable you can even run the script offline at first.

## You can help!

If you use mutt with a particular host or domain, put your server information in `domains.csv`! This will make everyone else who uses your email provider's life much easier!

Or you can help monetarily via [Patreon](https://patreon.com/lukesmith) or [Paypal](https://paypal.me/LukeMSmith)!

## Notes

Mail is stored in `~/.mail`. mutt configs and caches for each account are in `~/.config/mutt/accounts/`. Encypted passwords are in `~/.config/mutt/credentials`. A "personal" muttrc, with the macros for switching accounts and the default config is in `~/.config/mutt/personal.muttrc`.

## Todo

* Expand the list of server information in `domains.csv`.
* Add an option to update passwords.
