.POSIX:

OS = $(shell uname -s)
ifndef PREFIX
  PREFIX = /usr/local
endif
ifndef MANPREFIX
  MANPREFIX = $(PREFIX)/share/man
endif

install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	mkdir -p $(DESTDIR)$(PREFIX)/lib/mutt-wizard
	cp -f bin/mw bin/mailsync $(DESTDIR)$(PREFIX)/bin/
	cp -f lib/openfile $(DESTDIR)$(PREFIX)/lib/mutt-wizard
	chmod 755 $(DESTDIR)$(PREFIX)/bin/mw $(DESTDIR)$(PREFIX)/bin/mailsync $(DESTDIR)$(PREFIX)/lib/mutt-wizard/openfile
	mkdir -p $(DESTDIR)$(PREFIX)/share/mutt-wizard
	chmod 755 $(DESTDIR)$(PREFIX)/share/mutt-wizard
	cp -f share/mailcap share/domains.csv share/mutt-wizard.muttrc share/switch.muttrc $(DESTDIR)$(PREFIX)/share/mutt-wizard
	chmod 644 $(DESTDIR)$(PREFIX)/share/mutt-wizard/mailcap $(DESTDIR)$(PREFIX)/share/mutt-wizard/domains.csv $(DESTDIR)$(PREFIX)/share/mutt-wizard/mutt-wizard.muttrc $(DESTDIR)$(PREFIX)/share/mutt-wizard/switch.muttrc
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	cp -f mw.1 $(DESTDIR)$(MANPREFIX)/man1/mw.1
	cp -f mailsync.1 $(DESTDIR)$(MANPREFIX)/man1/mailsync.1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/mw.1 $(DESTDIR)$(MANPREFIX)/man1/mailsync.1
	if [ "$(PREFIX)" ]; then \
		sed -iba 's:/usr/local:$(PREFIX):' $(DESTDIR)$(PREFIX)/share/mutt-wizard/mutt-wizard.muttrc; \
		rm -f $(DESTDIR)$(PREFIX)/share/mutt-wizard/mutt-wizard.muttrcba; \
		sed -iba 's:/usr/local:$(PREFIX):' $(DESTDIR)$(PREFIX)/bin/mw; \
		rm -f $(DESTDIR)$(PREFIX)/bin/mwba; \
		sed -iba 's:/usr/local:$(PREFIX):' $(DESTDIR)$(MANPREFIX)/man1/mw.1; \
		rm -f $(DESTDIR)$(MANPREFIX)/man1/mw.1ba; \
		sed -iba 's:/usr/local:$(PREFIX):' $(DESTDIR)$(PREFIX)/share/mutt-wizard/mailcap; \
		rm -f $(DESTDIR)$(PREFIX)/share/mutt-wizard/mailcapba; \
	fi

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/mw $(DESTDIR)$(PREFIX)/bin/mailsync $(DESTDIR)$(PREFIX)/lib/mutt-wizard/openfile
	rm -rf $(DESTDIR)$(PREFIX)/share/mutt-wizard  $(DESTDIR)$(PREFIX)/lib/mutt-wizard
	rm -f $(DESTDIR)$(MANPREFIX)/man1/mw.1  $(DESTDIR)$(MANPREFIX)/man1/mailsync.1

.PHONY: install uninstall
