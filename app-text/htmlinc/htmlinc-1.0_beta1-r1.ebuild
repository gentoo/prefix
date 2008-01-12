# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/htmlinc/htmlinc-1.0_beta1-r1.ebuild,v 1.3 2008/01/11 21:23:11 grobian Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="HTML Include System by Ulli Meybohm"
HOMEPAGE="http://www.meybohm.de/"
SRC_URI="http://meybohm.de/files/${PN}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND="virtual/libc"
S=${WORKDIR}/htmlinc

src_unpack() {
	unpack ${A}
	epatch ${FILESDIR}/htmlinc-gcc3-gentoo.patch
}

src_compile() {
	emake CFLAGS="${CXXFLAGS} -Wall" || die
}

src_install() {
	dobin htmlinc
	dodoc README
}
