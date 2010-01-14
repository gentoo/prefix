# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/crossdev/crossdev-20100108.ebuild,v 1.1 2010/01/08 10:52:54 vapier Exp $

if [[ ${PV} == "99999999" ]] ; then
	EGIT_REPO_URI="git://git.overlays.gentoo.org/proj/crossdev.git"
	inherit git
	SRC_URI=""
	#KEYWORDS=""
else
	SRC_URI="mirror://gentoo/${P}.tar.lzma
		http://dev.gentoo.org/~vapier/dist/${P}.tar.lzma"
KEYWORDS=""
fi

DESCRIPTION="Gentoo Cross-toolchain generator"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
IUSE=""

RDEPEND=">=sys-apps/portage-2.1
	app-shells/bash
	!sys-devel/crossdev-wrappers"
DEPEND=""

src_install() {
	emake install DESTDIR="${D}" || die
}
