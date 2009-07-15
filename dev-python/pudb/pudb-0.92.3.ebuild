# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pudb/pudb-0.92.3.ebuild,v 1.1 2009/07/03 14:01:38 grozin Exp $
inherit distutils
DESCRIPTION="A full-screen, console-based Python debugger"
HOMEPAGE="http://pypi.python.org/pypi/${PN}/"
SRC_URI="http://pypi.python.org/packages/source/p/${PN}/${P}.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86-interix ~x86-linux"
IUSE=""
RDEPEND="dev-python/urwid
	dev-python/pygments"
