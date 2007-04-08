# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/portage-manpages/portage-manpages-20070122.ebuild,v 1.2 2007/02/28 21:58:33 genstef Exp $

EAPI="prefix"

DESCRIPTION="collection of Gentoo manpages"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=""

src_install() {
	doman *.[0-9] || die
}
