# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pycrypto/pycrypto-2.0.1.ebuild,v 1.6 2006/01/29 11:33:03 grobian Exp $

EAPI="prefix"

inherit eutils distutils

DESCRIPTION="Python Cryptography Toolkit"
HOMEPAGE="http://www.amk.ca/python/code/crypto.html"
SRC_URI="http://www.amk.ca/files/python/crypto/${P}.tar.gz"

LICENSE="freedist"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE="bindist"

DEPEND="virtual/python"

src_unpack() {
	unpack ${A}
	cd "${S}"
	use bindist && epatch "${FILESDIR}"/${P}-bindist.patch
}

src_test() {
	python ./test.py || die "test failed"
}

DOCS="ACKS ChangeLog PKG-INFO README TODO Doc/pycrypt.tex"
