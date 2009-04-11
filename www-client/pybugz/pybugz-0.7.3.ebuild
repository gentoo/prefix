# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/pybugz/pybugz-0.7.3.ebuild,v 1.12 2009/03/28 22:17:19 williamh Exp $

inherit distutils eutils prefix

DESCRIPTION="Command line interface to (Gentoo) Bugzilla"
HOMEPAGE="http://pybugz.googlecode.com"
SRC_URI="http://pybugz.googlecode.com/files/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""
DEPEND="|| ( >=dev-lang/python-2.5
	( >=dev-lang/python-2.4
		dev-python/elementtree ) )"
		RDEPEND=""

		pkg_setup() {
			if ! built_with_use dev-lang/python readline; then
				eerror
				eerror "Python is not built with readline support."
				eerror "Please re-emerge python with readline  in your use flags."
				die "python must be built with readline support."
	fi
		}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.7.1-prefix.patch
	eprefixify bugz.py
}
