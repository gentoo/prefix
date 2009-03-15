# Sample makefile for pngcrush using gcc and GNU make.
# Glenn Randers-Pehrson
# Last modified:  19 February 2005
# Kapil Hari Paranjape
# Last modified:  12 June 2008
#
# Invoke this makefile from a shell prompt in the usual way; for example:
#
#	make -f Makefile
#
# This makefile builds a dynamically linked executable.

# macros --------------------------------------------------------------------

GAS_VERSION := $(shell as --version | sed -n -e's/GNU assembler (.*) //p')

PNGINC = /usr/include

CC ?= gcc
RM = rm -f

CFLAGS += -I. -Wall

O = .o
E =

# additional defines
DEFINES = -DPNG_USE_PNGGCCRD -DPNG_iCCP_SUPPORTED \
	-DPNG_iTXt_SUPPORTED -DPNG_USE_GLOBAL_ARRAYS \
	-DGAS_VERSION="\"${GAS_VERSION}\"" \

PNGCRUSH  = pngcrush

LIBS = -lpng -lz

OBJS  = pngcrush$(O)

EXES = $(PNGCRUSH)$(E)


# implicit make rules -------------------------------------------------------

.c$(O): png.h cexcept.h $(ZHDR)
	$(CC) -c $(CFLAGS) $(DEFINES) $<


# dependencies --------------------------------------------------------------

all:  $(EXES)

png.h:
	ln -s $(PNGINC)/png.h png.h

pngcrush$(O): pngcrush.c cexcept.h
	$(CC) -c $(CFLAGS) $(DEFINES) $<

$(PNGCRUSH)$(E): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

# maintenance ---------------------------------------------------------------

clean:
	$(RM) $(EXES) $(OBJS) png.h

install:
	mkdir -p $(DESTDIR)/usr/bin/
	cp $(PNGCRUSH)$(E) $(DESTDIR)/usr/bin/
	chmod 0755 $(DESTDIR)/usr/bin/$(PNGCRUSH)$(E)

