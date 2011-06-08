# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/build-docbook-catalog/build-docbook-catalog-1.4.ebuild,v 1.11 2011/03/29 02:17:56 flameeyes Exp $

inherit eutils prefix

DESCRIPTION="DocBook XML catalog auto-updater"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="http://dev.gentoo.org/~flameeyes/${PN}/${P}.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
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
	newbin ${P} ${PN} || die
}
