# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/build-docbook-catalog/build-docbook-catalog-1.2.ebuild,v 1.16 2007/03/01 17:21:10 genstef Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="DocBook XML catalog auto-updater"
HOMEPAGE="http://unknown/"
SRC_URI="mirror://gentoo/${P}.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
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
