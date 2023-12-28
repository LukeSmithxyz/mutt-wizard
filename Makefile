.POSIX:

PREFIX = /usr/local
MANPREFIX = $(PREFIX)/share/man

install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	mkdir -p $(DESTDIR)$(PREFIX)/lib/mutt-wizard
	mkdir -p $(DESTDIR)$(PREFIX)/share/mutt-wizard
	cp -f bin/mailsync $(DESTDIR)$(PREFIX)/bin
	cp -f lib/openfile $(DESTDIR)$(PREFIX)/lib/mutt-wizard
	chmod 755 $(DESTDIR)$(PREFIX)/share/mutt-wizard
	for shared in share/*; do \
		cp -f $$shared $(DESTDIR)$(PREFIX)/share/mutt-wizard; \
		chmod 644 $(DESTDIR)$(PREFIX)/share/mutt-wizard/$$(basename $(notdir $$shared)); \
	done
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	cp -f mailsync.1 $(DESTDIR)$(MANPREFIX)/man1/mailsync.1
	sed 's:/usr/local:$(PREFIX):' < share/mutt-wizard.muttrc > $(DESTDIR)$(PREFIX)/share/mutt-wizard/mutt-wizard.muttrc
	sed 's:/usr/local:$(PREFIX):' < share/mailcap > $(DESTDIR)$(PREFIX)/share/mutt-wizard/mailcap
	sed 's:/usr/local:$(PREFIX):' < bin/mw > $(DESTDIR)$(PREFIX)/bin/mw
	sed 's:/usr/local:$(PREFIX):' < mw.1 > $(DESTDIR)$(MANPREFIX)/man1/mw.1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/mw.1 $(DESTDIR)$(MANPREFIX)/man1/mailsync.1
	chmod 755 $(DESTDIR)$(PREFIX)/bin/mw $(DESTDIR)$(PREFIX)/bin/mailsync $(DESTDIR)$(PREFIX)/lib/mutt-wizard/openfile
	mkdir -p $(DESTDIR)$(PREFIX)/share/zsh/site-functions/
	chmod 755 $(DESTDIR)$(PREFIX)/share/zsh/site-functions/
	cp -f completion/_mutt-wizard.zsh $(DESTDIR)$(PREFIX)/share/zsh/site-functions/_mutt-wizard.zsh
	chmod 644 $(DESTDIR)$(PREFIX)/share/zsh/site-functions/_mutt-wizard.zsh

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/mw $(DESTDIR)$(PREFIX)/bin/mailsync $(DESTDIR)$(PREFIX)/lib/mutt-wizard/openfile
	rm -rf $(DESTDIR)$(PREFIX)/share/mutt-wizard  $(DESTDIR)$(PREFIX)/lib/mutt-wizard
	rm -f $(DESTDIR)$(MANPREFIX)/man1/mw.1  $(DESTDIR)$(MANPREFIX)/man1/mailsync.1
	rm -f $(DESTDIR)$(PREFIX)/share/zsh/site-functions/_mutt-wizard.zsh

.PHONY: install uninstall
