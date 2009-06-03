# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-zope/zopeinterface/zopeinterface-3.4.1.ebuild,v 1.7 2009/06/01 09:22:20 ssuominen Exp $

inherit distutils

MY_PN="zope.interface"
MY_P="${MY_PN}-${PV}"
DESCRIPTION="Standalone Zope interface library"
HOMEPAGE="http://pypi.python.org/pypi/zope.interface/"
SRC_URI="http://pypi.python.org/packages/source/z/${MY_PN}/${MY_P}.tar.gz"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

RDEPEND=">=dev-lang/python-2.4"
DEPEND="${RDEPEND}
	!net-zope/zodb"

S=${WORKDIR}/${MY_P}
DOCS="CHANGES.txt"
