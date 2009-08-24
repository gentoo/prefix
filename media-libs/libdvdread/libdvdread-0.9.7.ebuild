# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libdvdread/libdvdread-0.9.7.ebuild,v 1.18 2009/08/21 20:22:48 ssuominen Exp $

inherit eutils libtool autotools

DESCRIPTION="Provides a simple foundation for reading DVD-Video images"
HOMEPAGE="http://www.dtek.chalmers.se/groups/dvd/"
SRC_URI="http://www.dtek.chalmers.se/groups/dvd/dist/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

RDEPEND=">=media-libs/libdvdcss-1.1.1"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-udfsymbols.patch
	eautoreconf
}

src_compile() {
	local myconf=""
	econf ${myconf} || die "./configure failed"
	emake || die "make failed"
}

src_install() {
	emake install DESTDIR="${D}" || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README TODO

	# install executables
	dobin src/.libs/* || die
	cd "${ED}"/usr/bin
	mv ifo_dump ifo_dump_dvdread || die
}
