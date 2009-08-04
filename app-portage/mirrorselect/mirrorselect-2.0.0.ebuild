# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/mirrorselect/mirrorselect-2.0.0.ebuild,v 1.2 2009/08/04 02:27:43 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit python prefix

DESCRIPTION="Tool to help select distfiles mirrors for Gentoo"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

RDEPEND="dev-lang/python[xml]
	dev-util/dialog
	net-analyzer/netselect"

RESTRICT_PYTHON_ABIS="3*"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.4.1-prefix.patch
	eprefixify mirrorselect
}

src_install() {
	newsbin main.py ${PN} || die

	installation() {
		insinto $(python_get_sitedir)
		doins -r ${PN}/
	}
	python_execute_function installation

	doman ${PN}.8 || die
}

pkg_postinst() {
	python_mod_optimize ${PN}
}

pkg_postrm() {
	python_mod_cleanup ${PN}
}
