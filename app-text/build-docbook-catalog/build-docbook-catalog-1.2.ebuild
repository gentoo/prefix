# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/app-text/build-docbook-catalog/build-docbook-catalog-1.2.ebuild,v 1.15 2006/10/24 09:58:36 uberlord Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="DocBook XML catalog auto-updater"
HOMEPAGE="http://unknown/"
SRC_URI="mirror://gentoo/${P}.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND=""

S=${WORKDIR}

src_unpack() {
        unpack ${A}
        cd ${S}
        epatch "${FILESDIR}"/${P}-prefix.patch
        eprefixify build-docbook-catalog-1.2
}

src_install() {
	newbin ${P} ${PN} || die
}
