# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/texinfo/texinfo-4.11-r1.ebuild,v 1.12 2008/04/19 06:57:14 vapier Exp $

inherit flag-o-matic

DESCRIPTION="The GNU info program and utilities"
HOMEPAGE="http://www.gnu.org/software/texinfo/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls static"

RDEPEND="!=app-text/tetex-2*
	>=sys-libs/ncurses-5.2-r2
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	sys-apps/help2man"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# pull in ctype.h for misc string function prototypes,
	# but _after_ config.h (or have troubles with _LARGE_FILES on aix)
	sed -i '/include[ \t]*["<]config\.h[>"]/a#include <ctype.h>' system.h 
	epatch "${FILESDIR}"/${P}-dir-entry.patch #198545
	epatch "${FILESDIR}"/${P}-test-tex.patch #195313
	epatch "${FILESDIR}"/${P}-test.patch #215359
	epatch "${FILESDIR}"/${P}-parallel-build.patch #214127

	epatch "${FILESDIR}"/${P}-prefix.patch
	epatch "${FILESDIR}"/${P}-high-precision.patch #200662
	epatch "${FILESDIR}"/${P}-aix.patch

	# FreeBSD requires install-sh, but usptream don't have it marked
	# exec, #195076
	chmod +x build-aux/install-sh
}

src_compile() {
	use static && append-ldflags -static
	econf $(use_enable nls) || die
	emake || die "emake"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"

	dodoc AUTHORS ChangeLog INTRODUCTION NEWS README TODO
	newdoc info/README README.info
	newdoc makeinfo/README README.makeinfo

	rm -f "${ED}"/usr/lib/charset.alias #195148
}
