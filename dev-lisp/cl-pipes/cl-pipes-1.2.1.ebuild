# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lisp/cl-pipes/cl-pipes-1.2.1.ebuild,v 1.11 2008/03/27 16:18:45 armin76 Exp $

inherit common-lisp

DESCRIPTION="Common Lisp library for pipes or streams"
HOMEPAGE="http://packages.debian.org/unstable/devel/cl-pipes"
SRC_URI="mirror://debian/pool/main/c/cl-pipes/${PN}_${PV}.orig.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""
DEPEND="dev-lisp/common-lisp-controller
	virtual/commonlisp"

CLPACKAGE=pipes

src_install() {
	common-lisp-install *.lisp *.asd
	common-lisp-system-symlink
	dodoc COPYING
}
