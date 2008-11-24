# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit eutils autotools

DESCRIPTION="top for UNIX systems"
HOMEPAGE="http://unixtop.sourceforge.net/"
SRC_URI="mirror://sourceforge/unixtop/top-${PV/_/}.tar.bz2"

LICENSE="unixtop"
SLOT="0"
KEYWORDS="~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="sys-libs/ncurses"
DEPEND="${RDEPEND}"

S=${WORKDIR}/top-${PV/_/}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-ncurses.patch
	epatch "${FILESDIR}"/${P}-no-AX-macros.patch
	eautoreconf
}

src_compile() {
	# don't do bi-arch cruft on hosts that support that, such as Solaris
	export enable_dualarch=no
	econf || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc README FAQ Y2K
}
