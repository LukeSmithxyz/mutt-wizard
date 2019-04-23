.POSIX:

PREFIX = /usr
MANPREFIX = $(PREFIX)/share/man

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
	mkdir -p $(DESTDIR)$(PREFIX)/share/mutt-wizard
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	cp -f mailcap $(DESTDIR)$(PREFIX)/share/mutt-wizard
	cp -f mutt-wizard.muttrc $(DESTDIR)$(PREFIX)/share/mutt-wizard
	cp -f domains.csv $(DESTDIR)$(PREFIX)/share/mutt-wizard
	cp -f mw.1 $(DESTDIR)$(MANPREFIX)/man1/mw.1

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/mw
	rm -f $(DESTDIR)$(PREFIX)/bin/mailsync
	rm -f $(DESTDIR)$(PREFIX)/bin/openfile
	rm -f $(DESTDIR)$(PREFIX)/bin/muttimage
	rm -rf $(DESTDIR)$(PREFIX)/share/mutt-wizard

.PHONY: install uninstall
