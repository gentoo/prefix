# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/mocker/mocker-0.10.1.ebuild,v 1.3 2009/02/15 22:30:06 patrick Exp $

inherit distutils

DESCRIPTION="Platform for Python test doubles: mocks, stubs, fakes, and dummies"
HOMEPAGE="http://labix.org/mocker"
SRC_URI="http://launchpad.net/${PN}/trunk/${PV}/+download/${P}.tar.bz2"
LICENSE="PSF-2.4"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
SLOT="0"
IUSE=""

src_test() {
	PYTHONPATH=. "${python}" test.py || die "Tests failed"
}
