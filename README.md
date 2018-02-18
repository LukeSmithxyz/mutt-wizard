# Luke's mutt Wizard for automatic Neomutt and OfflineIMAP configuration!

![mutt wizard preview](etc/mw.png)

Mutt is one of the most rewarding programs one can use, but can be a pain in the ass to configure. Since my job is making power-user tools available for the masses I want to create a tool that automates most of mutt configuration so that users can simply give their email address and get a /comfy/ setup. At that, I don't just want a mutt wizard, but an offlineIMAP wizard, so users can easily access their mail offline as well, and a wizard that makes it easy to store passwords securely using gpg.

The mutt-wizard is all of this in a simple ncurses menu. It's really just a little bash script, but one that can save countless people thousands of combined manhours of frustratingly trying to get all the moving pieces working together.

## User interface

The system takes an email and autodetect its server settings, generating a muttrc and offlineimaprc profile automatically. If it can't do so, it simply prompts you for these (which you can easily look up) and will put them all in the right places. You get:

+ Automatic configuration of mutt and offlineimap
+ Automatic encryption and safe storage of passwords which are used by mutt and offlineimap when necessary
+ Multiple account management in mutt: jump from account to account with the `i` prefix in mutt: `i1`: first email account, `i5`: fifth, etc.
+ Easy movement to mail folders in mutt: `gi`: go to inbox, `gs` to sent mail, `ga` to archive, `gS` to spam, `gd` to drafts, etc.
+ Some default controls and colors. This system is going to be integrated into my [public auto-rice script](https://larbs.xyz) so I want it to look pretty and be usable out the box.

### Will it work on my email? (95% yes)

Yes! At this point, the only problems are the unexpected ones. Please try it, and if you do run into problems, email me at [luke@lukesmith.xyz](mailto:luke@lukesmith.xyz)! I've tried the system personally on Gmail, Teknik.io, cock.li and Yandex, while others have tried other providers.

One email provider which I think will *not* work (and will never work) is Proton Mail, but that's only because they require encryption through their web client IIRC.

Note also that Gmail and some providers require you to enable sign-ins from third-party (or as they call it "less secure") applications to be able to load mail with mutt and offlineimap. Be sure to enable that!

## Installation and Dependencies

dialog, neomutt and offlineimap should be installed. You also need to have a GPG public/private key pair for the wizard to automatically store your passwords. Otherwise you'll have to store them insecurely in plaintext files without the help of the wizard. The whole repo should be cloned to `~/.config/mutt/`. (If you have a previous mutt folder, you'll want to back it up or delete it first.)

```
git clone https://github.com/LukeSmithxyz/mutt-wizard.git ~/.config/mutt
```

Just run `mutt-wizard.sh` for all the options, to install an account:

* First, select the "Add an account" option and give the script your account information.
* Second, in a separate terminal, start your mail sync by running `offlineimap` or `offlineimap -a <your account name>`. This will start downloading all your mail for offline access.
* Third, once your mailbox has started to download, reenter the script and select the "Auto-detect mailboxes" open. This will finalize the install and let you open up mutt to see your mail.

Whenever you want to check for mail, just run the `offlineimap` command again.

### "Wait? The script asks for my passwords?"

Look at the code. The script takes the passwords you give it, encrypts them immediately with your own GPG key, and shreds the leftovers. Nothing malicious; it's all there! If it makes you comfortable you can even run the script offline at first.

## You can help!

If you use mutt with a particular host or domain, put your server information in `domains.csv`! This will make everyone else who uses your email provider's life much easier!

Or you can help monetarily via [Patreon](https://patreon.com/lukesmith) or [Paypal](https://paypal.me/LukeMSmith)!

## Notes

Mail is stored in `~/.mail`. mutt configs and caches for each account are in `~/.config/mutt/accounts/`. Encypted passwords are in `~/.config/mutt/credentials`. A "personal" muttrc, with the macros for switching accounts and the default config is in `~/.config/mutt/personal.muttrc`.

## Todo

* Expand the list of server information in `domains.csv`, possibly porting the Thunderbird autoconfigure settings.
