# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/build-docbook-catalog/build-docbook-catalog-1.4.ebuild,v 1.8 2008/12/07 11:45:47 vapier Exp $

inherit eutils prefix

DESCRIPTION="DocBook XML catalog auto-updater"
HOMEPAGE="http://unknown/"
SRC_URI="mirror://gentoo/${P}.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="!<app-text/docbook-xsl-stylesheets-1.73.1"

S=${WORKDIR}

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify build-docbook-catalog-${PV}
}

src_install() {
	newbin ${P} ${PN} || die
}

pkg_postinst() {
	# prefix quirk :(
	einfo "A bug in the build-docbook-catalog script caused docbook files from"
	einfo "the Prefix not being recognised.  Please wait while we regenerate"
	einfo "your ${EPREFIX}/etc/xml/catalog"
	build-docbook-catalog
}
