# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/pybugz/pybugz-0.7.3.ebuild,v 1.2 2008/01/04 12:51:45 jokey Exp $

EAPI="prefix"

inherit distutils eutils

DESCRIPTION="Command line interface to (Gentoo) Bugzilla"
HOMEPAGE="http://pybugz.googlecode.com"
SRC_URI="http://pybugz.googlecode.com/files/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86 ~x86-fbsd ~x86-macos"
IUSE=""
DEPEND="|| ( >=dev-lang/python-2.5
	( >=dev-lang/python-2.4
		dev-python/elementtree ) )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.7.1-prefix.patch
	eprefixify bugz.py
}
