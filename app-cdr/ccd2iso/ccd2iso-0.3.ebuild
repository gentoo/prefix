# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/ccd2iso/ccd2iso-0.3.ebuild,v 1.1 2007/04/01 07:28:53 vapier Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Converts CloneCD images (popular under Windows) to ISOs"
HOMEPAGE="http://sourceforge.net/projects/ccd2iso/"
SRC_URI="mirror://sourceforge/ccd2iso/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-solaris"
IUSE=""

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-headers.patch
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog NEWS README TODO
}
