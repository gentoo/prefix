# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/liblrdf/liblrdf-0.4.0.ebuild,v 1.11 2009/02/12 17:41:53 jer Exp $

inherit autotools libtool base

DESCRIPTION="A library for the manipulation of RDF file in LADSPA plugins"
HOMEPAGE="http://lrdf.sourceforge.net"
SRC_URI="mirror://sourceforge/lrdf/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

RDEPEND=">=media-libs/raptor-0.9.12
	>=media-libs/ladspa-sdk-1.12"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${P}-dontbuild-tests.patch
)

src_unpack() {
	base_src_unpack
	cd "${S}"

	eautoreconf
	elibtoolize
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README
}
