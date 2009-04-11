# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lisp/cl-parse-number/cl-parse-number-1.0-r1.ebuild,v 1.9 2008/02/06 21:23:42 grobian Exp $

inherit common-lisp

DESCRIPTION="Common Lisp library to parse any number string"
HOMEPAGE="http://www.mapcar.org/~mrd/utilities/
	http://www.cliki.net/parse-number
	http://packages.debian.org/unstable/devel/cl-parse-number.html"
SRC_URI="mirror://debian/pool/main/c/cl-parse-number/cl-parse-number_1.0.orig.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""
DEPEND="dev-lisp/common-lisp-controller
	virtual/commonlisp"

CLPACKAGE=parse-number

src_install() {
	common-lisp-install *.lisp ${FILESDIR}/parse-number.asd
	common-lisp-system-symlink
}
