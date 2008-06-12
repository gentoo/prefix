# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/fpconst/fpconst-0.7.3.ebuild,v 1.5 2008/01/17 17:57:35 grobian Exp $

EAPI="prefix"

inherit distutils

DESCRIPTION="Python Module for handling IEEE 754 floating point special values"
HOMEPAGE="http://chaco.bst.rochester.edu:8080/statcomp/projects/RStatServer/fpconst/"
SRC_URI="mirror://sourceforge/rsoap/${P}.tar.gz"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
SLOT="0"
LICENSE="GPL-2"
IUSE=""

DEPEND=""
RDEPEND=""

DOCS="pep-0754.txt"
