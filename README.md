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

## YOU CAN HELP

If you use mutt with a particular host or domain, put your server information in `domains.csv`! This will make everyone else who uses your email provider's life much easier!

Or you can help monetarily via [Patreon](https://patreon.com/lukesmith) or [Paypal](https://paypal.me/LukeMSmith)!

## Notes

Mail is stored in `~/.mail`. mutt configs and caches for each account are in `~/.config/mutt/accounts/`. Encypted passwords are in `~/.config/mutt/credentials`. A "personal" muttrc, with the macros for switching accounts and the default config is in `~/.config/mutt/personal.muttrc`.

## Todo

* Expand the list of server information in `domains.csv`, including adding spoolfiles/records/postponed folders for each account.
* Write scripts that do the following:
	* Stat `~/.offlineimaprc` and the the mutt configs to see what accounts are currently available. (**Done**, currently in `removeaccount.sh`; needs integration.)
	* Delete a profile from above if requested. (**Done**, currently in `removeaccount.sh`; needs integration.)
	* Add a profile above if requested, including:
		* An automatic search of `domains.csv` for server information. (**Done**)
		* An ncurses menu for inputing server settings if not available in `domains.csv`. (Soon, see `manual.sh`)
		* Differential actions for Gmail accounts since these are distinct in offlineIMAP. (**Done**)
	* Configure notmuch with all accounts.
	* A prompt for adding encypted passwords for each account available.
		* Or directions for adding plain text passwords if desired.
