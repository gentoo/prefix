# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/amrnb/amrnb-7.0.0.2.ebuild,v 1.6 2009/05/05 13:30:41 jer Exp $

SPEC_VER="26104-700"

DESCRIPTION="Wrapper library for 3GPP Adaptive Multi-Rate Floating-point Speech Codec"
HOMEPAGE="http://www.penguin.cz/~utx/amr"
SRC_URI="http://ftp.penguin.cz/pub/users/utx/amr/${P}.tar.bz2
	http://www.3gpp.org/ftp/Specs/archive/26_series/26.104/${SPEC_VER}.zip"

LICENSE="LGPL-2 as-is"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

RESTRICT="mirror"

RDEPEND=""
DEPEND="app-arch/unzip"

#Bug 232636
export LC_ALL=C

src_unpack() {
	unpack ${P}.tar.bz2
	cd "${S}"
	cp "${DISTDIR}"/${SPEC_VER}.zip .
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README TODO
}
