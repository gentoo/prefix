# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pyyaml/pyyaml-3.05.ebuild,v 1.1 2007/10/05 23:01:23 sbriesen Exp $

EAPI="prefix"

inherit distutils

MY_P="PyYAML-${PV}"

DESCRIPTION="YAML parser and emitter for Python"
HOMEPAGE="http://pyyaml.org/wiki/PyYAML"
SRC_URI="http://pyyaml.org/download/pyyaml/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~x86-macos"
IUSE="libyaml"

DEPENDS="libyaml? ( dev-libs/libyaml dev-python/pyrex )"

S="${WORKDIR}/${MY_P}"

PYTHON_MODNAME="yaml"
DOCS="LICENSE"

src_unpack() {
	distutils_src_unpack
	if use libyaml; then
		cd "${S}"
		mv -f setup.py setup_native.py
		sed -i -e "s:\(from setup\):\1_native:g" setup_with_libyaml.py
		ln -snf setup_with_libyaml.py setup.py
	fi
}

src_install() {
	distutils_src_install
	insinto /usr/share/doc/${PF}/examples
	doins -r examples/.
}
