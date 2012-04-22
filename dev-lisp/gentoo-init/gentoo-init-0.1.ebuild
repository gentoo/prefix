# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lisp/gentoo-init/gentoo-init-0.1.ebuild,v 1.11 2012/04/07 10:29:17 neurogeek Exp $

EAPI="3"

inherit eutils prefix

DESCRIPTION="Simple ASDF-BINARY-LOCATIONS configuration for Gentoo Common Lisp ports."
HOMEPAGE="http://www.gentoo.org/proj/en/lisp/common-lisp/guide.xml"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

S=${WORKDIR}

DEPEND="dev-lisp/asdf-binary-locations"
RDEPEND="${DEPEND}"

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
