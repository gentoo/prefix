# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/chrpath/chrpath-0.13.ebuild,v 1.5 2005/05/01 16:44:35 hansmi Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="chrpath can modify the rpath and runpath of ELF executables"
HOMEPAGE="http://freshmeat.net/projects/chrpath/"
SRC_URI="ftp://ftp.hungry.com/pub/hungry/chrpath/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~amd64 ~sparc-solaris ~x86 ~x86-solaris"

IUSE=""

DEPEND="virtual/libc"

src_install() {
	dobin chrpath
	doman chrpath.1
	dodoc ChangeLog AUTHORS NEWS README
}
