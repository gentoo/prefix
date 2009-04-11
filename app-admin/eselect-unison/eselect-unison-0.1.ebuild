# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-unison/eselect-unison-0.1.ebuild,v 1.8 2008/06/30 20:37:46 armin76 Exp $

inherit eutils

DESCRIPTION="unison module for eselect"
HOMEPAGE="http://www.gentoo.org/proj/en/eselect/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"

IUSE=""
DEPEND=""
RDEPEND=">=app-admin/eselect-1.0.5"

src_install() {
	local MODULEDIR="/usr/share/eselect/modules"
	local MODULE="unison"
	dodir ${MODULEDIR}
	insinto ${MODULEDIR}
	newins "${FILESDIR}/${MODULE}.eselect-${PVR}" ${MODULE}.eselect || die "failed to install"
	# sloppy Prefix adjustment
	dosed 's:${ROOT}:${ROOT}'"${EPREFIX}"':g' ${MODULEDIR}/${MODULE}.eselect
}
