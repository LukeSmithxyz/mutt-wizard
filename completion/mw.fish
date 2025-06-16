# Fish shell completions for mw (mutt-wizard) command

# Main flags (first argument)
complete -c mw -n "not __fish_seen_subcommand_from -a -l -d -D -y -Y -t -T -r" -s a -d "Add an email address"
complete -c mw -n "not __fish_seen_subcommand_from -a -l -d -D -y -Y -t -T -r" -s l -d "List email addresses configured"
complete -c mw -n "not __fish_seen_subcommand_from -a -l -d -D -y -Y -t -T -r" -s d -d "Remove an already added address"
complete -c mw -n "not __fish_seen_subcommand_from -a -l -d -D -y -Y -t -T -r" -s D -d "Force remove account without confirmation"
complete -c mw -n "not __fish_seen_subcommand_from -a -l -d -D -y -Y -t -T -r" -s y -d "Sync mail for account by name"
complete -c mw -n "not __fish_seen_subcommand_from -a -l -d -D -y -Y -t -T -r" -s Y -d "Sync mail for all accounts"
complete -c mw -n "not __fish_seen_subcommand_from -a -l -d -D -y -Y -t -T -r" -s t -d "Toggle automatic mailsync every <number> minutes"
complete -c mw -n "not __fish_seen_subcommand_from -a -l -d -D -y -Y -t -T -r" -s T -d "Toggle automatic mailsync every 10 minutes"
complete -c mw -n "not __fish_seen_subcommand_from -a -l -d -D -y -Y -t -T -r" -s r -d "Order account numbers"

# Sub-options for -a (add email address)
complete -c mw -n "__fish_seen_subcommand_from -a" -s u -d "Account login name if not full address"
complete -c mw -n "__fish_seen_subcommand_from -a" -s n -d "Real name to be on the email account"
complete -c mw -n "__fish_seen_subcommand_from -a" -s i -d "IMAP/POP server address"
complete -c mw -n "__fish_seen_subcommand_from -a" -s I -d "IMAP/POP server port"
complete -c mw -n "__fish_seen_subcommand_from -a" -s s -d "SMTP server address"
complete -c mw -n "__fish_seen_subcommand_from -a" -s S -d "SMTP server port"
complete -c mw -n "__fish_seen_subcommand_from -a" -s x -d "Password for account (recommended to be in double quotes)"
complete -c mw -n "__fish_seen_subcommand_from -a" -s P -d "Pass Prefix (prefix of the file where password is stored)"
complete -c mw -n "__fish_seen_subcommand_from -a" -s p -d "Add for a POP server instead of IMAP"
complete -c mw -n "__fish_seen_subcommand_from -a" -s X -d "Delete an account's local email too when deleting"
complete -c mw -n "__fish_seen_subcommand_from -a" -s o -d "Configure address, but keep mail online"
complete -c mw -n "__fish_seen_subcommand_from -a" -s f -d "Assume typical English mailboxes without attempting log-on"

# Email address completions for -D and -y flags
complete -c mw -n "__fish_seen_subcommand_from -D" -f -a "(mw -l 2>/dev/null | cut -f2)"
complete -c mw -n "__fish_seen_subcommand_from -y" -f -a "(mw -l 2>/dev/null | cut -f2)"
