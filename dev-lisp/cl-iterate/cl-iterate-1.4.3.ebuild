# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lisp/cl-iterate/cl-iterate-1.4.3.ebuild,v 1.1 2006/08/25 05:48:59 mkennedy Exp $

inherit common-lisp eutils

DESCRIPTION="ITERATE is a lispy and extensible replacement for the Common Lisp LOOP macro"
HOMEPAGE="http://common-lisp.net/project/iterate/
	http://www.cliki.net/iterate"
SRC_URI="http://common-lisp.net/project/iterate/releases/iterate-${PV}.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="virtual/commonlisp
	dev-lisp/common-lisp-controller"

S=${WORKDIR}/iterate-${PV}

CLPACKAGE=iterate

src_unpack() {
	unpack ${A}
	rm ${S}/Makefile
}

src_install() {
	common-lisp-install *.{lisp,asd}
	common-lisp-system-symlink
	insinto /usr/share/doc/${PF}
	doins doc/*.pdf
}
