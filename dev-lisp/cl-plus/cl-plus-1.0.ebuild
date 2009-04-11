# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lisp/cl-plus/cl-plus-1.0.ebuild,v 1.7 2008/02/06 21:29:20 grobian Exp $

inherit common-lisp eutils

DEB_PV=1

DESCRIPTION="Common Lisp extensions such as a DEFCONSTANT wrappers"
HOMEPAGE="http://packages.debian.org/unstable/devel/cl-plus"
SRC_URI="mirror://debian/pool/main/c/${PN}/${PN}_${PV}.orig.tar.gz
	mirror://gentoo/${PN}_${PV}-${DEB_PV}.diff.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="dev-lisp/common-lisp-controller
	virtual/commonlisp"

CLPACKAGE=cl-plus

src_unpack() {
	unpack ${A}
	epatch ${PN}_${PV}-${DEB_PV}.diff || die
}

src_install() {
	common-lisp-install *.asd *.lisp
	common-lisp-system-symlink
	do-debian-credits
}
