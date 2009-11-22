# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/gccxml/gccxml-0.9.0_pre20090516-r1.ebuild,v 1.1 2009/11/16 15:17:46 scarabeus Exp $

EAPI="2"

inherit cmake-utils

DESCRIPTION="XML output extension to GCC"
HOMEPAGE="http://www.gccxml.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

src_prepare() {
	# patch below taken from Debian
	sed -i \
		-e 's/xatexit.c//' \
		"${S}/GCC/libiberty/CMakeLists.txt" || die "sed failed"
}
