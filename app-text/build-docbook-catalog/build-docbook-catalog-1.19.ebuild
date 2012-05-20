# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/build-docbook-catalog/build-docbook-catalog-1.19.ebuild,v 1.2 2012/04/26 17:20:54 aballier Exp $

EAPI="4"

DESCRIPTION="DocBook XML catalog auto-updater"
HOMEPAGE="http://sources.gentoo.org/gentoo-src/build-docbook-catalog/"
SRC_URI="mirror://gentoo/${P}.tar.xz
	http://dev.gentoo.org/~vapier/dist/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="|| ( sys-apps/util-linux app-misc/getopt )
	!<app-text/docbook-xsl-stylesheets-1.73.1"
DEPEND=""

src_prepare() {
	sed -i -e "/^\(ROOTCONFDIR\|DOCBOOKDIR\)=/s:=/:=${EPREFIX}/:" build-docbook-catalog || die
	sed -i -e "/^\(SYSCONFDIR\|PREFIX\) = /s:= /:= ${EPREFIX}/:" Makefile || die
}

pkg_postinst() {
	# New version -> regen files
	build-docbook-catalog
}
