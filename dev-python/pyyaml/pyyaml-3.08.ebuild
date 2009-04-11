# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pyyaml/pyyaml-3.08.ebuild,v 1.2 2009/02/17 17:58:23 patrick Exp $

NEED_PYTHON="2.3"

inherit distutils

MY_P="PyYAML-${PV}"

DESCRIPTION="YAML parser and emitter for Python"
HOMEPAGE="http://pyyaml.org/wiki/PyYAML"
SRC_URI="http://pyyaml.org/download/${PN}/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86-linux ~x86-macos"
IUSE="examples libyaml"

DEPEND="libyaml? ( dev-libs/libyaml dev-python/pyrex )"
RDEPEND="libyaml? ( dev-libs/libyaml )"

S="${WORKDIR}/${MY_P}"

PYTHON_MODNAME="yaml"

src_install() {
	distutils_src_install
	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/.
	fi
}
