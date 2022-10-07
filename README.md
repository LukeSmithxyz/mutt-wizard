# mutt-wizard

https://muttwizard.com/

Get this great stuff without effort:

- A full-featured and autoconfigured email client on the terminal with neomutt
- Mail stored offline enabling the ability to:
    * view and write emails while you're away from
      the internet
    * make backups
- Provides a `mailsync` script that can be scheduled to run as often as you
  like, which downloads/syncs mail and notifies you when new mail has arrived.

Specifically, this wizard:

- Determines your email server's IMAP and SMTP servers and ports
- Creates dotfiles for `neomutt`, `isync`, and `msmtp` appropriate for your
  email address
- Encrypts and locally stores your password for easy remote access, accessible
  only by your GPG key
- Handles as many as nine separate email accounts automatically
- Auto-creates bindings to switch between accounts or between mailboxes
- Provides sensible defaults and an attractive appearance for the neomutt email
  client
- If mutt-wizard doesn't know your server's IMAP/SMTP info by default, it will
  prompt you for them and will put them in all the right places.

## Install

#### Dependencies

- `neomutt` - the email client. (If you are using Gentoo GNU/Linux, you will need the `sasl` use flag to be enabled)
- `curl` - tests connections (required at install).
- `isync` - downloads and syncs the mail (required if storing IMAP mail locally).
- `msmtp` - sends the email.
- `pass` - safely encrypts passwords (required at install).

**Note**: There's a chance of errors if you use a slow-release distro like
Ubuntu, Debian, or Mint. If you get errors in `neomutt`, install the most
recent version manually or manually remove the offending lines in the config in
`/usr/share/mutt-wizard/mutt-wizard.muttrc`.

```bash
git clone https://github.com/LukeSmithxyz/mutt-wizard
cd mutt-wizard
sudo make install
```

A user of Arch-based distros can also install the current mutt-wizard release from the AUR as
[mutt-wizard](https://aur.archlinux.org/packages/mutt-wizard/), or the Github master branch, [mutt-wizard-git](https://aur.archlinux.org/packages/mutt-wizard-git/).

### Optional Dependencies

- `pam-gnupg` - Automatically logs you into your GPG key on login so you will
  never need to input your password once logged on to your system. Check the
  repo and directions out [here](https://github.com/cruegge/pam-gnupg).
- `lynx` - view HTML email in neomutt.
- `notmuch` - index and search mail. Install it and run `notmuch setup`, tell
  it that your mail is in `~/.local/share/mail/` (although `mw` will do this
  automatically if you haven't set notmuch up before). You can run it in mutt
  with <kbd>ctrl-f</kbd>. Run `notmuch new` to process new mail.
- `abook` - a terminal-based address book. Pressing tab while typing an address
  to send mail to will suggest contacts that are in your abook.
- `urlview` - outputs urls in mail to browser.
- `cronie` - (or any other major cronjob manager) to set up automatic mail
  syncing.
- `mpop` - If you want to use POP protocol instead of IMAP.


## Usage

The mutt-wizard runs via the command `mw`. Once setup is complete, you'll use
`neomutt` to access your mail.

- `mw -a you@email.com` -- add a new email account
- `mw -l` -- list existing accounts
- `mw -y your@email.com` -- sync an email account
- `mw -Y` -- sync all configured email accounts
- `mw -d` -- choose an account to delete
- `mw -D your@email.com` -- delete account settings without confirmation
- `mw -t 30` -- toggle automatic mailsync to every 30 minutes
- `mw -T` -- toggle mailsync without specifying minutes (default is 10)
- `mw -r` -- reorder account shortcut numbers
- `pass edit mw-your@email.com` -- revise an account's password

### Options usable when adding an account

#### Providing arguments

- `-u` -- Give an account username if different from the email address.
- `-n` -- A real name to be used by the account. Put in quotations if multiple
  words.
- `-i` -- IMAP server address
- `-I` -- IMAP server port (otherwise assumed to be 993)
- `-s` -- SMTP server address
- `-S` -- SMTP server port (otherwise assumed to be 465)
- `-m` -- Maximum number of emails to be kept offline. No maximum is default
  functionality.
- `-x` -- Account password. You will be prompted for it otherwise.

#### General Settings

- `-f` -- Assume mailbox names and force account configuration without
  connecting online at all.
- `-o` -- Configure mutt for an account, but do not keep mail offline.
- `-p` -- Use POP protocol instead of IMAP (requires `mpop` installed).

## Neomutt user interface

To give you an example of the interface, here's an idea:

- <kbd>m</kbd> - send mail (uses your default `$EDITOR` to write)
- <kbd>j</kbd>/<kbd>k</kbd> and <kbd>d</kbd>/<kbd>u</kbd> - vim-like bindings to go down and up (or <kbd>d</kbd>/<kbd>u</kbd> to go
  down/up a page).
- <kbd>l</kbd> - open mail, or attachment page or attachment
- <kbd>h</kbd> - the opposite of <kbd>l</kbd>
- <kbd>r</kbd>/<kbd>R</kbd> - reply/reply all to highlighted mail
- <kbd>s</kbd> - save selected mail or selected attachment
- <kbd>gs</kbd>,<kbd>gi</kbd>,<kbd>ga</kbd>,<kbd>gd</kbd>,<kbd>gS</kbd> - Press <kbd>g</kbd> followed by another letter to change
  mailbox: <kbd>s</kbd>ent, <kbd>i</kbd>nbox, <kbd>a</kbd>rchive, <kbd>d</kbd>rafts, <kbd>S</kbd>pam, etc.
- <kbd>M</kbd> and <kbd>C</kbd> - For <kbd>M</kbd>ove and <kbd>C</kbd>opy: follow them with one of the mailbox
  letters above, i.e. <kbd>MS</kbd> means "move to Spam".
- <kbd>i#</kbd> - Press <kbd>i</kbd> followed by a number 1-9 to go to a different account. If you
  add 9 accounts via mutt-wizard, they will each be assigned a number.
- <kbd>a</kbd> to add address/person to abook and <kbd>Tab</kbd> while typing address to complete
  one from abook.
- <kbd>?</kbd> - see all keyboard shortcuts
- <kbd>ctrl-j</kbd>/<kbd>ctrl-k</kbd> - move up and down in sidebar, <kbd>ctrl-o</kbd> opens mailbox.
- <kbd>ctrl-b</kbd> - open a menu to select a URL you want to open in your browser.
- <kbd>p</kbd> - encrypt/sign your message (in compose view, before sending the email).

## Additional functionality

- `pam-gnupg` - Automatically logs you into your GPG key on login, so you will
  never need to input your password once logged on to your system. Check the
  repo and directions out [here](https://github.com/cruegge/pam-gnupg).
- `lynx` - View HTML email in neomutt.
- `notmuch` - Index and search mail. Install it and run `notmuch setup`, tell it
  that your mail is in `~/.local/share/mail/` (although `mw` will do this
  automatically if you haven't set notmuch up before). You can run it in mutt
  with <kbd>ctrl-f</kbd>. Run `notmuch new` to process new mail.
- `abook` - A terminal-based address book. Pressing tab while typing an address
  to send mail to will suggest contacts that are in your abook.
- `urlview` - Outputs URLs in an email to your browser.

## New stuff and improvements since the original release

- `mw` is now scriptable with command-line options and can run successfully
  without any interaction, making it possible to deploy in a script.
- `isync`/`mbsync` has replaced `offlineimap` as the backend. Offlineimap was
  error-prone, bloated, used obsolete Python 2 modules, and required separate
  steps to install the system.
- `mw` is now an installed program instead of just a script needed to be kept in
  your mutt folder.
- `dialog` is no longer used and the interface is simply text commands.
- More autogenerated shortcuts that allow quickly moving and copying mail
  between boxes.
- More elegant attachment handling. Image/video/pdf attachments without relying
  on the neomutt instance.
- abook integration by default.
- The messy template files and other directories have been moved or removed,
  leaving a clean config folder.
- msmtp configs moved to `~/.config/` and mail default location moved to
  `~/.local/share/mail/`, reducing mess in `~`.
- `pass` is used as a password manager instead of separately saving passwords.
- Script is POSIX sh compliant.
- Error handling for the many people who don't read or follow directions. Fewer
  errors generally.
- Addition of a manual `man mw`
- Now handles POP protocol via `mpop` for those who prefer it (add an account
  with the `-p` option). POP configs are still generated automatically.

## Help the Project!


- Try mutt-wizard out on weird machines and weird email addresses and report any
  errors.
- Open a PR to add new server information into `domains.csv` so their users can
  more easily use mutt-wizard.
- If nothing else, donate:
	- XMR: `8AzeWXhJvYJ1VeENHcNXCR1dLMgDALreZ1BdooZVjRKndv6myr3t1ue6C4ML2an5fWSpcP1sTDA9nKUMevkukDXG6chRjNv`
	- BTC: `bc1qacqfp36ffv9mafechmvk8f6r8qy4tual6rcm9p`

## Details for Tinkerers

- The critical `mutt`/`neomutt` files are in `~/.config/mutt/`.
- Put whatever global settings you want in `muttrc`. mutt-wizard will add some
  lines to this file, which you shouldn't remove unless you know what you're
  doing, but you can move them up/down over your config lines if you need to. If
  you get binding conflict errors in mutt, you might need to do this.
- Each of the accounts that mutt-wizard generates will have custom settings set
  in a separate file in `accounts/`. You can edit these freely if you want to
  tinker with settings specific to an account.
- In `/usr/share/mutt-wizard` are several global config files, including
  `mutt-wizard`'s default settings. You can override this in your `muttrc` if
  you wish.

## Watch out for these things

- Gmail accounts need to create an
  [App Password](https://support.google.com/accounts/answer/185833?hl=en) to
  use with  "less secure" applications. This password is single-use (i.e.
  for setup) and will be stored and encrypted locally. Enabling third-party
  applications requires turning off two-factor authentication and this will
  circumvent that. You might also need to manually "Enable IMAP" in the
  settings.
- If you have a university email or enterprise-hosted email for work, there
  might be other hurdles or two-factor authentication you have to jump through.
  Some, for example, will want you to create a separate IMAP password, etc.
- `isync` is not fully UTF-8 compatible, so non-Latin characters may be garbled
  (although sync should succeed). `mw` will also not auto-create mailbox
  shortcuts since it is looking for English mailbox names. I strongly recommend
  you to set your email language to English on your mail server to avoid these
  problems.

## License

mutt-wizard is free/libre software. This program is released under the GPLv3
license, which you can find in the file [LICENSE](LICENSE).
