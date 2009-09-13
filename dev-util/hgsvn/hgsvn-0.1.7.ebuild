# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/hgsvn/hgsvn-0.1.7.ebuild,v 1.1 2009/09/11 23:32:13 patrick Exp $

NEED_PYTHON=2.4

inherit distutils

DESCRIPTION="A set of scripts to work locally on Subversion checkouts using Mercurial"
HOMEPAGE="http://cheeseshop.python.org/pypi/hgsvn"
SRC_URI="http://cheeseshop.python.org/packages/source/h/hgsvn/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86-linux ~x86-macos"
IUSE=""

DEPEND="dev-python/setuptools"
RDEPEND="${DEPEND}
	dev-util/subversion
	|| ( >=dev-lang/python-2.5 dev-python/elementtree )"
