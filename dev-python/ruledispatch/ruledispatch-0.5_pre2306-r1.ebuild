# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/ruledispatch/ruledispatch-0.5_pre2306-r1.ebuild,v 1.1 2009/07/25 13:42:30 neurogeek Exp $

EAPI="2"
NEED_PYTHON=2.4

inherit distutils versionator

MY_PN=RuleDispatch
MY_P=${MY_PN}-$(get_version_component_range 1-2)a0.dev-$(get_version_component_range 3-)
MY_P=${MY_P/pre/r}

DESCRIPTION="Rule-based Dispatching and Generic Functions"
HOMEPAGE="http://peak.telecommunity.com/"
SRC_URI="mirror://gentoo/${MY_P}.tar.gz"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
LICENSE="|| ( PSF-2.4 ZPL )"
SLOT="0"
IUSE=""

RDEPEND=">=dev-python/pyprotocols-1.0_pre2306"
DEPEND="${RDEPEND}
	>=dev-python/setuptools-0.6_rc5"

S="${WORKDIR}/${MY_PN}"

PYTHON_MODNAME="dispatch"

src_prepare(){
	epatch "${FILESDIR}/${PN}_as_syntax_fix.patch"
}

src_test() {
	PYTHONPATH=./src/ "${python}" setup.py test || die "tests failed"
}
