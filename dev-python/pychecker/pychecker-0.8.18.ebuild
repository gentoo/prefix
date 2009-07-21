# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pychecker/pychecker-0.8.18.ebuild,v 1.4 2009/07/17 18:25:03 nixnut Exp $

EAPI="2"

inherit distutils eutils

DESCRIPTION="Tool for finding common bugs in python source code"
SRC_URI="mirror://sourceforge/pychecker/${P}.tar.gz"
HOMEPAGE="http://pychecker.sourceforge.net/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND="virtual/python"
RDEPEND="${DEPEND}"

DOCS="pycheckrc"

src_prepare() {
	distutils_src_prepare
	epatch "${FILESDIR}"/pychecker-0.8.17-no-data-files.patch
	epatch "${FILESDIR}"/pychecker-0.8.18-pychecker2.patch
	sed -e 's:root = self\.distribution\.get_command_obj("install")\.root:&\.rstrip("/"):' -i setup.py || die "sed setup.py failed"
}

pkg_postinst() {
	python_mod_optimize "$(python_get_sitedir)"
}

pkg_postrm() {
	python_mod_cleanup "$(python_get_sitedir)"
}
