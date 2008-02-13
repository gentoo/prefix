# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/liblrdf/liblrdf-0.4.0.ebuild,v 1.8 2008/02/12 12:37:57 flameeyes Exp $

EAPI="prefix"

inherit libtool

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

src_unpack() {
	unpack ${A}

	elibtoolize
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README
}
