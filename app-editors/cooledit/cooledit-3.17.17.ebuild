# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/cooledit/cooledit-3.17.17.ebuild,v 1.4 2008/01/11 20:42:02 grobian Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Cooledit is a full featured multiple window text editor"
HOMEPAGE="http://freshmeat.net/projects/cooledit/"
SRC_URI="ftp://ftp.ibiblio.org/pub/Linux/apps/editors/X/cooledit/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="nls spell"

RDEPEND="x11-libs/libX11
	app-text/ispell"
DEPEND="${RDEPEND}
	x11-libs/libXpm"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/cooledit-3.17.17-gcc4.patch
}

src_compile() {
	# Fix for bug 40152 (04 Feb 2004 agriffis)
	addwrite /dev/ptym/clone:/dev/ptmx
	econf $(use_enable nls)
	emake || die "emake failed"
}

src_install() {
	make install DESTDIR=${D} || die "install failed"
}
