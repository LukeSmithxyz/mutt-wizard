# Luke's mutt Wizard for automatic Neomutt and OfflineIMAP configuration!

Mutt is one of the most rewarding programs one can use, but can be a pain in the ass to configure. Since my job is making power-user tools available for the masses I want to create a tool that automates most of mutt configuration so that users can simply give their email address and get a /comfy/ setup. At that, I don't just want a mutt wizard, but an offlineIMAP wizard, so users can easily access their mail offline as well, and a wizard that makes it easy to store passwords securely using gpg.

## User interface

* The main scripts `mutt-wizard.sh` has options to add new email accounts, or remove unwanted ones. For email providers listed in the `autoconf/domains.csv` file, this will be 100% automatic and for other email addresses it will simply prompt you for you email's SMTP and IMAP server settings (which you can easily look up).
* The scripts will take that information and autogenerate mutt and offlineimap config files so you don't have to worry about them.
* It also creates a email-specific settings for your muttrc, which are outputed in the `accounts/` directory in your mutt directory.
	* The script will automatically handle multiple accounts. Each will be assigned a number 1-9, and you can jump from one to another in mutt by pressing `i` and then that number. You can change the numbers by manually editing the macros in `personal.muttrc`.
	* For most accounts, you can jump to sent mail with `gs`, drafts with `gd` and the inbox with `gi`. I haven't worked this out for every domain.
* It uses your gpg encryption to store your encrypted password in `credentials/`, where there are also two scripts that allow mutt and offlineIMAP to decrypt the passwords when needed.

### Will it work on my email? (95% yes)

Gmail accounts, cock.li accounts, teknik.io, mail.com accounts should work 100% already. Still, email me at [luke@lukesmith.xyz](mailto:luke@lukesmith.xyz) if you run into something.

Accounts with Yandex, Yahoo, AOL, Outlook, Office 365 and iCloud should work, but the hotkeys to jump from inbox to sent to drafts, etc. won't be automatic because I don't yet know the folder structures of these accounts. If you try the script on these accounts, please check what the structure looks like in `~/.mail/<account name>/` and tell me what you see and I can automate this!

For all other accounts, the wizard will prompt you to put in your SMTP and IMAP server information; obviously it will know exactly what to do with everything, you just have to give it the info.

The email accounts that *won't* work with the script would include Proton Mail accounts (which I believe are totally encrypted and only available by the web client) and possibly some University emails. In the latter case, you may just have to search your university's website for the specifics. I'll just say I redirect my university email to another account to avoid this problem and others.

## Installation and Dependencies

dialog, neomutt and offlineimap should be installed. The contents of this repo should go directly in `~/.config/mutt/` and run from there. You also need to have a GPG public/private key pair for the wizard to automatically store your passwords. Otherwise you'll have to store them insecurely in plaintext files without the help of the wizard. As a note, if you uuse a distribution like Void that uses GPG2 and not GPG, you should symlink /usr/bin/gpg to /usr/bin/gpg2 or wherever the GPG2 binary lives.

Just run `mutt-wizard.sh` for all the options.

Once you successfully run the script, you should be able to simply run `offlineimap` to start your mail sync (which will be big at first). Opening `neomutt`, you should see your mail.

### "Wait? The script asks for my passwords?"

Look at the code. The script takes the passwords you give it, encrypts them immediately with your own GPG key, and shreds the leftovers. Nothing malicious; it's all there. If it makes you comfortable you can even run the script offline at first.

## You can help!

If you use mutt with a particular host or domain, put your server information in `domains.csv`! This will make everyone else who uses your email provider's life much easier!

Or you can help monetarily via [Patreon](https://patreon.com/lukesmith) or [Paypal](https://paypal.me/LukeMSmith)!

## Notes

Mail is stored in `~/.mail`. mutt configs and caches for each account are in `~/.config/mutt/accounts/`. Encypted passwords are in `~/.config/mutt/credentials`. A "personal" muttrc, with the macros for switching accounts and the default config is in `~/.config/mutt/personal.muttrc`.

## Todo

* Expand the list of server information in `domains.csv`, including adding spoolfiles/records/postponed folders for each account.
