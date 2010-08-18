# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/build-docbook-catalog/build-docbook-catalog-1.5.ebuild,v 1.1 2009/08/23 16:08:48 flameeyes Exp $

inherit eutils prefix

DESCRIPTION="DocBook XML catalog auto-updater"
HOMEPAGE="http://unknown/"
SRC_URI="mirror://gentoo/${P}.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="|| ( sys-apps/util-linux app-misc/getopt )
	!<app-text/docbook-xsl-stylesheets-1.73.1"
DEPEND=""

S=${WORKDIR}

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify build-docbook-catalog-${PV}
}

src_install() {
	keepdir /etc/xml
	newbin ${P} ${PN} || die "newbin failed"
}
