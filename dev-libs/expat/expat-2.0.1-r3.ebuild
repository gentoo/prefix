# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/expat/expat-2.0.1-r3.ebuild,v 1.8 2010/03/09 22:04:59 josejx Exp $

inherit eutils libtool autotools

DESCRIPTION="XML parsing libraries"
HOMEPAGE="http://expat.sourceforge.net/"
SRC_URI="mirror://sourceforge/expat/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	# fix segmentation fault in python tests (bug #197043)
	epatch "${FILESDIR}/${P}-check_stopped_parser.patch"

	epatch "${FILESDIR}"/${P}-fix_bug_1990430.patch \
		"${FILESDIR}"/${P}-CVE-2009-3560-revised.patch

	# this eautoreconf is required _at least_ by all interix and winnt
	# platforms to add shared library support.
	local mylibtoolize=libtoolize
	[[ ${CHOST} == *-darwin* ]] && mylibtoolize=glibtoolize
	local mylt=$(type -P ${mylibtoolize})
	cp "${mylt%/bin/${mylibtoolize}}"/share/aclocal/libtool.m4 conftools/libtool.m4
	AT_M4DIR="conftools" eautoreconf

	epunt_cxx
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc Changes README || die
	dohtml doc/* || die
}
