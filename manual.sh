# The stuff for manually putting in server settings.
# Will be added to main script as option eventually.
remotehost=$(\
	dialog --inputbox "Insert the IMAP server for your email provider (excluding the port number)" 10 60 \
	3>&1 1>&2 2>&3 3>&- \
	)

dialog --inputbox "What is your server's IMAP port number? (Usually 993)" 10 60

smtpserver=$(\
	dialog --inputbox "Insert the SMTP server for your email provider (excluding the port number)" 10 60 \
	3>&1 1>&2 2>&3 3>&- \
	)
smtpport=$(\
dialog --inputbox "What is your server's SMTP port number? (Usually 587 or 465)" 10 60
	3>&1 1>&2 2>&3 3>&- \
	)
