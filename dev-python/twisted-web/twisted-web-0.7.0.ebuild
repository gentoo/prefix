# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/twisted-web/twisted-web-0.7.0.ebuild,v 1.3 2007/06/09 18:04:18 lavajoe Exp $

EAPI="prefix"

MY_PACKAGE=Web

inherit twisted eutils

DESCRIPTION="Twisted web server, programmable in Python"

KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~x86 ~x86-fbsd ~x86-macos"

DEPEND="=dev-python/twisted-2.5*"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.5.0-root-skip.patch
}
