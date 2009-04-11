# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/expat/expat-2.0.1-r1.ebuild,v 1.11 2009/03/23 15:43:31 loki_val Exp $

inherit eutils libtool autotools

DESCRIPTION="XML parsing libraries"
HOMEPAGE="http://expat.sourceforge.net/"
SRC_URI="mirror://sourceforge/expat/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND=""
DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	# fix segmentation fault in python tests (bug #197043)
	epatch "${FILESDIR}/${P}-check_stopped_parser.patch"

	local mylibtoolize=libtoolize
	[[ ${CHOST} == *-darwin* ]] && mylibtoolize=glibtoolize
	local mylt=$(type -P ${mylibtoolize})
	cp "${mylt%/bin/${mylibtoolize}}"/share/aclocal/libtool.m4 conftools/libtool.m4
	AT_M4DIR="conftools" eautoreconf
	epunt_cxx
}

src_install() {
	emake install DESTDIR="${D}" || die "emake install failed"
	dodoc Changes README || die "dodoc failed"
	dohtml doc/* || die "dohtml failed"
}

pkg_postinst() {
	ewarn "Please note that the soname of the library changed!"
	ewarn "If you are upgrading from a previous version you need"
	ewarn "to fix dynamic linking inconsistencies by executing:"
	ewarn "revdep-rebuild -X --library libexpat.so.0"
}
