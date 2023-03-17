#compdef mw

_arguments \
	'1:flag:->flags' \
	'*:: :->args'

case "$state" in
	flags)
		local -a opts
		opts=(
		'-a:Add an email address'
		'-l:List email addresses configured'
		'-d:Remove an already added address'
		'-D:Force remove account without confirmation'
		'-y:Sync mail for account by name'
		'-Y:Sync mail for all accounts'
		'-t:Toggle automatic mailsync every <number> minutes'
		'-T:Toggle automatic mailsync every 10 minutes'
		'-r:order account numbers'
		)
		_describe 'flags' opts
		;;
	args)
		case $line[1] in
			-a)
				_alternative \
				'args: :((
					-u\:"Account login name if not full address"
					-n\:"Real name to be on the email account"
					-i\:"IMAP/POP server address"
					-I\:"IMAP/POP server port"
					-s\:"SMTP server address"
					-S\:"SMTP server port"
					-x\:"Password for account (recommended to be in double quotes)"
					-P\:"Pass Prefix (prefix of the file where password is stored)"
					-p\:"Add for a POP server instead of IMAP."
					-X\:"Delete an account'"'"'s local email too when deleting."
					-o\:"Configure address, but keep mail online."
					-f\:"Assume typical English mailboxes without attempting log-on."
					))'
				;;
			-D|-y)
				_values 'email list' $(mw -l | cut -f2) 2>/dev/null
		esac
esac
