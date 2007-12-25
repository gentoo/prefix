# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lisp/gentoo-init/gentoo-init-0.1.ebuild,v 1.4 2007/12/08 16:42:41 drac Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Simple ASDF-BINARY-LOCATIONS configuration for Gentoo Common Lisp ports."
HOMEPAGE="http://www.gentoo.org/proj/en/lisp/common-lisp/guide.xml"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-macos ~x86-solaris"
IUSE=""

S=${WORKDIR}

DEPEND="dev-lisp/cl-asdf-binary-locations"

src_unpack() {
	cp "${FILESDIR}"/gentoo-init.lisp "${T}"
	cd "${T}"
	epatch "${FILESDIR}"/gentoo-init.lisp-prefix.patch
	eprefixify gentoo-init.lisp
}

src_install() {
	insinto /etc
	doins "${T}"/gentoo-init.lisp
}
