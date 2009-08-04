# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/kiwi/kiwi-1.9.26.ebuild,v 1.1 2009/08/04 03:30:06 arfrever Exp $

NEED_PYTHON="2.3"
SUPPORT_PYTHON_ABIS="1"

inherit distutils versionator

DESCRIPTION="Kiwi is a pure Python framework and set of enhanced PyGTK widgets"
HOMEPAGE="http://www.async.com.br/projects/kiwi/"
SRC_URI="http://download.gnome.org/sources/${PN}/$(get_version_component_range 1-2)/${P}.tar.gz"
LICENSE="LGPL-2.1"
SLOT="0"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE="examples"

DEPEND="dev-python/pygtk"
RDEPEND="${DEPEND}"

RESTRICT_PYTHON_ABIS="3*"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i \
		-e "s:share/doc/kiwi:share/doc/${PF}:g" \
		setup.py || die "sed failed"
}

src_install() {
	distutils_src_install

	if use examples ; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}
