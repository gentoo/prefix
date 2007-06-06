# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/mime-types/mime-types-7.ebuild,v 1.10 2007/06/03 21:39:11 welp Exp $

EAPI="prefix"

DESCRIPTION="Provides /etc/mime.types file"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=""

src_install() {
	insinto /etc
	doins mime.types || die
}
