# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libxspf/libxspf-1.2.0.ebuild,v 1.9 2012/05/06 22:49:59 pesa Exp $

EAPI=4

inherit eutils qt4-r2

DESCRIPTION="Playlist handling library"
HOMEPAGE="http://libspiff.sourceforge.net"
SRC_URI="mirror://sourceforge/libspiff/${P}.tar.bz2"

LICENSE="BSD LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="doc test"

RDEPEND=">=dev-libs/uriparser-0.7.5
	>=dev-libs/expat-2"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	test? ( >=dev-util/cpptest-1.1 )
	doc? (
		>=app-doc/doxygen-1.5.8
		media-gfx/graphviz
		x11-libs/qt-assistant:4
	)"

DOCS="AUTHORS ChangeLog NEWS README THANKS"
PATCHES=(
	"${FILESDIR}/${P}-gcc44.patch"
)

src_configure() {
	econf \
		--docdir="${EPREFIX}"/usr/share/doc/${PF} \
		$(use_enable test) \
		$(use_enable doc)
}

