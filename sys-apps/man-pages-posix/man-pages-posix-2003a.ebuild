# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/man-pages-posix/man-pages-posix-2003a.ebuild,v 1.11 2009/02/02 08:00:28 aballier Exp $

inherit eutils

MY_P="${PN}-${PV:0:4}-${PV:0-1}"
DESCRIPTION="POSIX man-pages (0p, 1p, 3p)"
HOMEPAGE="http://www.kernel.org/doc/man-pages/"
SRC_URI="mirror://kernel/linux/docs/man-pages/${PN}/${MY_P}.tar.bz2"

LICENSE="freedist"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""
RESTRICT="binchecks"

RDEPEND="virtual/man !<sys-apps/man-pages-3"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/man-pages-2.08-updates.patch
}

src_compile() { :; }

src_install() {
	emake install DESTDIR="${ED}" || die
	dodoc man-pages-*.Announce README Changes*
}
