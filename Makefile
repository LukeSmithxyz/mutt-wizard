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
	for script in bin/*; do \
		cp -f $$script $(DESTDIR)$(PREFIX)/bin/; \
		chmod 755 $(DESTDIR)$(PREFIX)/$$script; \
	done
	mkdir -p $(DESTDIR)$(PREFIX)/share/mutt-wizard
	chmod 755 $(DESTDIR)$(PREFIX)/share/mutt-wizard
	for shared in share/*; do \
		cp -f $$shared $(DESTDIR)$(PREFIX)/share/mutt-wizard; \
		chmod 644 $(DESTDIR)$(PREFIX)/share/mutt-wizard/$$(basename $(notdir $$shared)); \
	done
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	cp -f mw.1 $(DESTDIR)$(MANPREFIX)/man1/mw.1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/mw.1
	if [ "$(PREFIX)" ]; then \
		sed -iba 's:/usr/local:$(PREFIX):' $(DESTDIR)$(PREFIX)/share/mutt-wizard/mutt-wizard.muttrc; \
		rm -f $(DESTDIR)$(PREFIX)/share/mutt-wizard/mutt-wizard.muttrcba; \
		sed -iba 's:/usr/local:$(PREFIX):' $(DESTDIR)$(PREFIX)/bin/mw; \
		rm -f $(DESTDIR)$(PREFIX)/bin/mwba; \
		sed -iba 's:/usr/local:$(PREFIX):' $(DESTDIR)$(MANPREFIX)/man1/mw.1; \
		rm -f $(DESTDIR)$(MANPREFIX)/man1/mw.1ba; \
	fi

uninstall:
	for script in bin/*; do \
		rm -f $(DESTDIR)$(PREFIX)/$$script; \
	done
	rm -rf $(DESTDIR)$(PREFIX)/share/mutt-wizard
	rm -f $(DESTDIR)$(MANPREFIX)/man1/mw.1

.PHONY: install uninstall
