# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/twisted-web/twisted-web-8.1.0.ebuild,v 1.1 2008/05/25 20:29:21 lordvan Exp $

EAPI="prefix"

MY_PACKAGE=Web

inherit twisted eutils versionator

DESCRIPTION="Twisted web server, programmable in Python"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"

DEPEND="=dev-python/twisted-$(get_version_component_range 1-2)*"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.5.0-root-skip.patch
}
