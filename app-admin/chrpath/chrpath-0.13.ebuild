# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/chrpath/chrpath-0.13.ebuild,v 1.7 2008/01/03 15:19:41 vapier Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="chrpath can modify the rpath and runpath of ELF executables"
HOMEPAGE="http://freshmeat.net/projects/chrpath/"
SRC_URI="ftp://ftp.hungry.com/pub/hungry/chrpath/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~sparc-solaris ~x86 ~x86-fbsd ~x86-solaris"
IUSE=""

src_install() {
	dobin chrpath || die
	doman chrpath.1
	dodoc ChangeLog AUTHORS NEWS README
}
