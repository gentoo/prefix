# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lisp/cl-puri/cl-puri-1.5.ebuild,v 1.1 2006/11/19 17:52:52 mkennedy Exp $

inherit common-lisp

DESCRIPTION="Portable URI library for Common Lisp based on the Franz, Inc. :net.uri module."
HOMEPAGE="http://puri.b9.com/"
SRC_URI="http://files.b9.com/puri/puri-${PV}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""
DEPEND="dev-lisp/cl-ptester"

CLPACKAGE=puri

S=${WORKDIR}/puri-${PV}

src_install() {
	common-lisp-install *.lisp *.asd
	common-lisp-system-symlink
	dohtml uri.html
	dodoc README LICENSE
}
