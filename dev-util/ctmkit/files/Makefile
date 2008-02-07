# Portable Makefile for ctmkit
# Public domain by Matt Behrens <matt@zigg.com>
#
# Drop this in your ctm directory and 'make && sudo make install'.

DESTDIR=
PREFIX=/usr
BINDIR=${PREFIX}/bin

CFLAGS+=-Ilibmd
LIBMD_OBJS=libmd/md2c.o libmd/md4c.o libmd/md5c.o libmd/md2hl.o libmd/md4hl.o libmd/md5hl.o
CTM_OBJS=ctm/ctm/ctm.o ctm/ctm/ctm_input.o ctm/ctm/ctm_pass1.o ctm/ctm/ctm_pass2.o ctm/ctm/ctm_pass3.o ctm/ctm/ctm_syntax.o ctm/ctm/ctm_ed.o
CTM_RMAIL_OBJS=ctm/ctm_rmail/ctm_rmail.o ctm/ctm_rmail/error.o
MD5_OBJS=md5/md5.o

all:	bin/ctm bin/ctm_rmail bin/md5

clean:
	rm -f ${LIBMD_OBJS} ${CTM_OBJS} ${CTM_RMAIL_OBJS} libmd/md2hl.c libmd/md4hl.c libmd/md5hl.c libmd/libmd.a
	rm -rf bin

install:	all
	install -d ${DESTDIR}${BINDIR}
	install -c -m 755 bin/ctm ${DESTDIR}${BINDIR}/ctm
	install -c -m 755 bin/ctm_rmail ${DESTDIR}${BINDIR}/ctm_rmail
	install -c -m 755 bin/md5 ${DESTDIR}${BINDIR}/md5

libmd/md2hl.c: libmd/mdXhl.c
	sed -e 's/mdX/md2/g' -e 's/MDX/MD2/g' $< > $@

libmd/md4hl.c: libmd/mdXhl.c
	sed -e 's/mdX/md4/g' -e 's/MDX/MD4/g' $< > $@

libmd/md5hl.c: libmd/mdXhl.c
	sed -e 's/mdX/md5/g' -e 's/MDX/MD5/g' $< > $@

libmd/libmd.a:	${LIBMD_OBJS}
	ar r $@ ${LIBMD_OBJS}

bin/ctm:	${CTM_OBJS} libmd/libmd.a
	mkdir -p bin
	cc -o $@ ${CTM_OBJS} -Llibmd -lmd

bin/ctm_rmail:	${CTM_RMAIL_OBJS}
	mkdir -p bin
	cc -o $@ ${CTM_RMAIL_OBJS}

bin/md5:	${MD5_OBJS}
	mkdir -p bin
	cc -o $@ ${MD5_OBJS} -Llibmd -lmd

