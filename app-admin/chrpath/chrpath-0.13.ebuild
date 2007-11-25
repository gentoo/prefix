# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/chrpath/chrpath-0.13.ebuild,v 1.6 2007/07/03 18:58:59 uberlord Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="chrpath can modify the rpath and runpath of ELF executables"
HOMEPAGE="http://freshmeat.net/projects/chrpath/"
SRC_URI="ftp://ftp.hungry.com/pub/hungry/chrpath/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~amd64 ~sparc-solaris ~x86 ~x86-fbsd ~x86-solaris"

IUSE=""

DEPEND="virtual/libc"

src_install() {
	dobin chrpath
	doman chrpath.1
	dodoc ChangeLog AUTHORS NEWS README
}
