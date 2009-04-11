# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/amrwb/amrwb-7.0.0.2.ebuild,v 1.9 2008/05/25 09:04:18 aballier Exp $

SPEC_VER="26204-700"

DESCRIPTION="Wrapper library for 3GPP Adaptive Multi-Rate Wideband Floating-point Speech Codec"
HOMEPAGE="http://www.penguin.cz/~utx/amr"
SRC_URI="http://ftp.penguin.cz/pub/users/utx/amr/${P}.tar.bz2
	http://www.3gpp.org/ftp/Specs/archive/26_series/26.204/${SPEC_VER}.zip"

RESTRICT="mirror"

LICENSE="LGPL-2 as-is"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

RDEPEND=""
DEPEND="app-arch/unzip"

src_unpack() {
	unpack ${P}.tar.bz2
	cd "${S}"
	cp "${DISTDIR}"/${SPEC_VER}.zip .
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README TODO
}
