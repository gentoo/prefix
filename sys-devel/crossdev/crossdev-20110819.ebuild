# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/crossdev/crossdev-20110819.ebuild,v 1.1 2011/08/19 18:12:57 vapier Exp $

EAPI="3"

if [[ ${PV} == "99999999" ]] ; then
	EGIT_REPO_URI="git://git.overlays.gentoo.org/proj/crossdev.git"
	inherit git-2
	SRC_URI="mirror://gentoo/${P}.tar.xz
		http://dev.gentoo.org/~vapier/dist/${P}.tar.xz"
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
DEPEND="app-arch/xz-utils"

src_install() {
	emake install DESTDIR="${D}" || die
}
