# neomutt Offline email setup

Mutt is one of the most rewarding programs one can use, but can be a pain in the ass to configure. Since my job is making power-user tools available for the masses I want to create a tool that automates most of mutt configuration so that users can simply give their email address and get a /comfy/ setup. At that, I don't just want a mutt wizard, but an offlineIMAP wizard, so users can easily access their mail offline as well, and a wizard that makes it easy to store passwords securely using gpg.

## Dependencies

dialog, neomutt and offlineimap installed. The contents of this repo should go directly in `~/.config/mutt/` and run from there.

## Progress

* The main scripts `mutt_install.sh` can create or add an account from a domain in `domain.csv` to `~/.offlineimaprc` without a problem.
* It also creates a email-specific settings for your muttrc, which are outputed in the `accounts/` directory in your mutt directory.
	* The script will automatically handle multiple accounts. Each will be assigned a number 1-9, and you can jump from one to another in mutt by pressing `i` and then that number. You can change the numbers by manually editing the macros in `personal.muttrc`.
	* For most accounts, you can jump to sent mail with `gs`, drafts with `gd` and the inbox with `gi`. I haven't worked this out for every domain.
* It uses your gpg encryption to store your encrypted password in `credentials/`, where there are also two scripts that allow mutt and offlineIMAP to decrypt the passwords when needed.

### Verified to be working with

Gmail accounts, cock.li accounts, teknik.io, mail.com accounts should work 100% already. Still, email me at [luke@lukesmith.xyz](mailto:luke@lukesmith.xyz) if you run into something.

Accounts with Yandex, Yahoo, Aol, Outlook, Office 365 and iCloud should work, but the hotkeys to jump from inbox to sent to drafts, etc. won't be automatic because I don't yet know the folder structures of these accounts. If you try the script on these accounts, please check what the structure looks like in `~/.mail/<account name>/` and tell me what you see and I can automate this!

## You can help!

If you use mutt with a particular host or domain, put your server information in `domains.csv`! This will make everyone else who uses your email provider's life much easier!

Or you can help monetarily via [Patreon](https://patreon.com/lukesmith) or [Paypal](https://paypal.me/LukeMSmith)!

## Notes

Mail is stored in `~/.mail`. mutt configs and caches for each account are in `~/.config/mutt/accounts/`. Encypted passwords are in `~/.config/mutt/credentials`. A "personal" muttrc, with the macros for switching accounts and the default config is in `~/.config/mutt/personal.muttrc`.

## Todo

* Expand the list of server information in `domains.csv`, including adding spoolfiles/records/postponed folders for each account.
* An ncurses menu for inputing server settings if not available in `domains.csv`. (Soon, see `manual.sh`)
* Configure notmuch with all accounts.
* Move all scripts into one wizard script, integrating all the options.
