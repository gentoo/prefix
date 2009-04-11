# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/turbojson/turbojson-1.1.3.ebuild,v 1.1 2008/07/02 05:35:57 pythonhead Exp $

NEED_PYTHON=2.4

inherit distutils

KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

MY_PN=TurboJson
MY_P=${MY_PN}-${PV}

DESCRIPTION="TurboGears JSON file format support plugin"
HOMEPAGE="http://www.turbogears.org/docs/plugins/template.html"
#SRC_URI="http://files.turbogears.org/eggs/${MY_P}.tar.gz"
SRC_URI="http://pypi.python.org/packages/source/T/${MY_PN}/${MY_P}.tar.gz"
LICENSE="MIT"
SLOT="0"
IUSE="test"

RDEPEND="dev-python/ruledispatch
	dev-python/simplejson"
DEPEND="${RDEPEND}
	dev-python/setuptools
	test? ( dev-python/nose )"

S=${WORKDIR}/${MY_P}

src_test() {
	PYTHONPATH=. "${python}" setup.py test || die "tests failed"
}
