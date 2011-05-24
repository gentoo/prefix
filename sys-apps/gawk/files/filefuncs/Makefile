# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# Author:  Martin Schlemmer <azarah@gentoo.org>
# $Header: /var/cvsroot/gentoo-x86/sys-apps/gawk/files/filefuncs/Makefile,v 1.10 2009/05/16 22:02:25 vapier Exp $

CC ?= gcc
LD = $(CC)

MAJORVER = 0
MINORVER = 0.1

# Gentoo prefix specific cruft
ifdef EPREFIX
AWKINCDIR = $(EPREFIX)/usr/include/awk
else
AWKINCDIR = /usr/include/awk
endif
DESTDIR =

TARGET = filefuncs

LIBDIR = lib

# Gentoo specific cruft, you like it dont ya idiot
ifdef D
DESTDIR = $(D)
endif
ifdef S
AWKINCDIR = $(S)
endif

ifeq ($(KERNEL),Darwin)
TARGET_LIB = $(TARGET).$(MAJORVER).$(MINORVER).bundle
TARGET_LIB_M = $(TARGET).$(MAJORVER).bundle
TARGET_LIB_O = $(TARGET).bundle
else
TARGET_LIB = $(TARGET).so.$(MAJORVER).$(MINORVER)
TARGET_LIB_M = $(TARGET).so.$(MAJORVER)
TARGET_LIB_O = $(TARGET).so
endif

ifeq ($(KERNEL),AIX)
SHLIB = -shared
SHLDFLAGS = -Wl,-G
else
  ifeq ($(KERNEL),Darwin)
SHLIB = -bundle -undefined dynamic_lookup
SHLDFLAGS = 
  else
    ifeq ($(KERNEL),HPUX)
SHLIB = -shared
SHLDFLAGS = -Wl,+h -Wl,$(TARGET_LIB_M)
    else
      ifeq ($(KERNEL),Interix)
SHLIB = -shared
SHLDFLAGS = -Wl,-h -Wl,$(TARGET_LIB_M)
      else
SHLIB = -shared
SHLDFLAGS = -Wl,-soname -Wl,$(TARGET_LIB_M)
      endif
    endif
  endif
endif

all: $(TARGET_LIB)

$(TARGET).o: $(TARGET).c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(SHLIB) -Wall -DHAVE_CONFIG_H -c -O2 -fPIC -I$(AWKINCDIR) $^

$(TARGET_LIB): $(TARGET).o
	$(LD) $(LDFLAGS) -o $@ $(SHLIB) $(SHLDFLAGS) $^

install: $(TARGET_LIB)
	install -m 0755 -d $(DESTDIR)/$(LIBDIR)/rcscripts
	install -m 0755 $(TARGET_LIB) $(DESTDIR)/$(LIBDIR)/rcscripts
	ln -s $(TARGET_LIB) $(DESTDIR)/$(LIBDIR)/rcscripts/$(TARGET_LIB_M)
	ln -s $(TARGET_LIB) $(DESTDIR)/$(LIBDIR)/rcscripts/$(TARGET_LIB_O)

clean:
	rm -f $(TARGET)
	rm -f *.o *~ core
