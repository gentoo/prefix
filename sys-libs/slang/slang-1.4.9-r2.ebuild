# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/slang/slang-1.4.9-r2.ebuild,v 1.18 2007/03/18 17:15:01 grobian Exp $

EAPI="prefix"

inherit eutils multilib

# Patches are taken from http://www.suse.de/~nadvornik/slang/
# They were originally Red Hat and Debian's patches

DESCRIPTION="Console display library used by most text viewer"
HOMEPAGE="http://www.s-lang.org/"
SRC_URI="ftp://space.mit.edu/pub/davis/slang/v1.4/${P}.tar.bz2
	mirror://gentoo/${P}-patches.tar.gz"

LICENSE="|| ( GPL-2 Artistic )"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-solaris"
IUSE="cjk unicode"

DEPEND=">=sys-libs/ncurses-5.2-r2"

src_unpack() {
	unpack ${A}
	cd ${S}

	epatch ${WORKDIR}/${P}.patch
	[[ ${CHOST} == *-darwin* ]] || use userland_BSD || epatch ${WORKDIR}/${P}-fsuid.patch
	epatch ${WORKDIR}/${P}-autoconf.patch
	if use unicode ; then
		epatch ${WORKDIR}/slang-debian-utf8.patch
		epatch ${WORKDIR}/slang-utf8-acs.patch
		epatch ${WORKDIR}/slang-utf8-fix.patch
		epatch ${WORKDIR}/slang-utf8-fix2.patch
	fi

	epatch "${FILESDIR}/${P}-fbsdlink.patch"

	if use cjk ; then
		sed -i \
			-e "/SLANG_HAS_KANJI_SUPPORT/s/0/1/" \
			src/sl-feat.h
	fi
}

src_compile() {
	export LANG=C
	export LC_ALL=C
	econf || die "econf failed"
	emake -j1 all elf || die "make failed"
}

src_install() {
	make install install-elf DESTDIR=${D} || die "make install failed"
	chmod a+rx "${ED}"/usr/$(get_libdir)/libslang*$(get_libname)* || die "chmod failed"

	if use unicode ; then
		for i in ${ED}/usr/$(get_libdir)/libslang-utf8* ; do
			local libslang=${i/${ED}/}
			dosym ${libslang} ${libslang/-utf8/}
		done
		dosym /usr/$(get_libdir)/libslang{-utf8,}.a
	fi

	rm -rf ${ED}/usr/doc
	dodoc NEWS README *.txt
	dodoc doc/*.txt doc/internal/*.txt doc/text/*.txt
	dohtml doc/*.html
}
