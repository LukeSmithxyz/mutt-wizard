.POSIX:

OS = $(shell uname -s)
ifndef PREFIX
  PREFIX = /usr
endif
ifndef MANPREFIX
  MANPREFIX = $(PREFIX)/share/man
endif

install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	mkdir -p $(DESTDIR)$(PREFIX)/lib/mutt-wizard
	cp -f bin/mutt-wizard bin/mailsync $(DESTDIR)$(PREFIX)/bin/
	cp -f lib/openfile $(DESTDIR)$(PREFIX)/lib/mutt-wizard
	chmod 755 $(DESTDIR)$(PREFIX)/bin/mutt-wizard $(DESTDIR)$(PREFIX)/bin/mailsync $(DESTDIR)$(PREFIX)/lib/mutt-wizard/openfile
	mkdir -p $(DESTDIR)$(PREFIX)/share/mutt-wizard
	chmod 755 $(DESTDIR)$(PREFIX)/share/mutt-wizard
	cp -f share/mailcap share/domains.csv share/mutt-wizard.muttrc share/switch.muttrc share/theme-LukeSmith.muttrc share/theme-gruvbox.muttrc $(DESTDIR)$(PREFIX)/share/mutt-wizard
	chmod 644 $(DESTDIR)$(PREFIX)/share/mutt-wizard/mailcap $(DESTDIR)$(PREFIX)/share/mutt-wizard/domains.csv $(DESTDIR)$(PREFIX)/share/mutt-wizard/mutt-wizard.muttrc $(DESTDIR)$(PREFIX)/share/mutt-wizard/switch.muttrc $(DESTDIR)$(PREFIX)/share/mutt-wizard/theme-LukeSmith.muttrc $(DESTDIR)$(PREFIX)/share/mutt-wizard/theme-gruvbox.muttrc
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	cp -f mutt-wizard.1 $(DESTDIR)$(MANPREFIX)/man1/mutt-wizard.1
	cp -f mailsync.1 $(DESTDIR)$(MANPREFIX)/man1/mailsync.1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/mutt-wizard.1 $(DESTDIR)$(MANPREFIX)/man1/mailsync.1
	if [ "$(PREFIX)" ]; then \
		sed -iba 's:/usr:$(PREFIX):' $(DESTDIR)$(PREFIX)/share/mutt-wizard/mutt-wizard.muttrc; \
		rm -f $(DESTDIR)$(PREFIX)/share/mutt-wizard/mutt-wizard.muttrcba; \
		sed -iba 's:/usr:$(PREFIX):' $(DESTDIR)$(PREFIX)/bin/mutt-wizard; \
		rm -f $(DESTDIR)$(PREFIX)/bin/mutt-wizardba; \
		sed -iba 's:/usr:$(PREFIX):' $(DESTDIR)$(MANPREFIX)/man1/mutt-wizard.1; \
		rm -f $(DESTDIR)$(MANPREFIX)/man1/mutt-wizard.1ba; \
		sed -iba 's:/usr:$(PREFIX):' $(DESTDIR)$(PREFIX)/share/mutt-wizard/mailcap; \
		rm -f $(DESTDIR)$(PREFIX)/share/mutt-wizard/mailcapba; \
	fi

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/mutt-wizard $(DESTDIR)$(PREFIX)/bin/mailsync
	rm -rf $(DESTDIR)$(PREFIX)/share/mutt-wizard  $(DESTDIR)$(PREFIX)/lib/mutt-wizard
	rm -f $(DESTDIR)$(MANPREFIX)/man1/mutt-wizard.1  $(DESTDIR)$(MANPREFIX)/man1/mailsync.1

.PHONY: install uninstall
