# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/texinfo/texinfo-4.11-r1.ebuild,v 1.1 2007/11/12 07:25:39 vapier Exp $

EAPI="prefix"

inherit flag-o-matic

DESCRIPTION="The GNU info program and utilities"
HOMEPAGE="http://www.gnu.org/software/texinfo/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-aix ~ppc-macos ~sparc-solaris ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"
IUSE="nls static"

RDEPEND="!=app-text/tetex-2*
	>=sys-libs/ncurses-5.2-r2
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# pull in ctype.h for misc string function prototypes
	sed -i '1i#include <ctype.h>' system.h
	epatch "${FILESDIR}"/${P}-dir-entry.patch #198545
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify util/texi2{dvi,pdf}

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
	# Parallel install fails (key.c)
	emake -j1 DESTDIR="${D}" install || die "install failed"

	dodoc AUTHORS ChangeLog INTRODUCTION NEWS README TODO
	newdoc info/README README.info
	newdoc makeinfo/README README.makeinfo

	rm -f "${ED}"/usr/lib/charset.alias #195148
}
