# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-im/naim/naim-0.11.8.3.2.ebuild,v 1.1 2009/09/23 09:43:57 ssuominen Exp $

EAPI=2

DESCRIPTION="An ncurses based AOL Instant Messenger"
HOMEPAGE="http://naim.n.ml.org"
SRC_URI="http://naim.googlecode.com/files/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="debug screen"

RDEPEND="sys-libs/ncurses
	screen? ( app-misc/screen )"
DEPEND="${RDEPEND}"

MAKEOPTS="${MAKEOPTS} -j1"

src_configure() {
	local myconf="--disable-dnsupdate"

	use debug && myconf="${myconf} --enable-debug"
	use screen && myconf="${myconf} --enable-detach"

	econf \
		--with-pkgdocdir="${EPREFIX}"/usr/share/doc/${PF} \
		${myconf}
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS BUGS ChangeLog FAQ NEWS README doc/*.hlp
}
