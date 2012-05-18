# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/mirrorselect/mirrorselect-2.1.0-r3.ebuild,v 1.6 2012/02/22 17:17:25 zmedico Exp $

EAPI="3"
SUPPORT_PYTHON_ABIS="1"
PYTHON_DEPEND=2
PYTHON_USE_WITH="xml"

inherit eutils python prefix

DESCRIPTION="Tool to help select distfiles mirrors for Gentoo"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

RDEPEND="
	dev-util/dialog
	net-analyzer/netselect"

RESTRICT_PYTHON_ABIS="3*"

src_prepare() {
	# bug 312753
	epatch "${FILESDIR}/0001-Fix-rsync-mirror-selectection.patch"
	# bug 330611
	epatch "${FILESDIR}/0002-Check-for-a-valid-mirrorselect-test-file.patch"

	epatch "${FILESDIR}"/${PN}-2.0.0-prefix.patch
	eprefixify main.py

	python_convert_shebangs 2 main.py mirrorselect/mirrorparser3.py
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
