.POSIX:

PREFIX = /usr/local

install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f bin/mw $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/mw
	cp -f bin/openfile $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/openfile
	cp -f bin/muttimage $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/muttimage
	cp -f bin/mailsync $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/mailsync
	mkdir -p /usr/share/mutt-wizard
	cp -f mailcap /usr/share/mutt-wizard
	cp -f muttrc /usr/share/mutt-wizard
	cp -f domains.csv /usr/share/mutt-wizard

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/mw
	rm -f $(DESTDIR)$(PREFIX)/bin/mailsync
	rm -f $(DESTDIR)$(PREFIX)/bin/openfile
	rm -f $(DESTDIR)$(PREFIX)/bin/muttimage
	rm -rf /usr/share/mutt-wizard

.PHONY: install uninstall
