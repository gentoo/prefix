# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-boost/eselect-boost-0.3.ebuild,v 1.11 2010/03/21 15:10:05 ranger Exp $

inherit multilib

DESCRIPTION="boost module for eselect"
HOMEPAGE="http://www.gentoo.org/proj/en/eselect/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~ia64-hpux ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=">=app-admin/eselect-1.0.5"

src_install() {
	local mdir="/usr/share/eselect/modules"
	dodir ${mdir}
	sed -e "s|%LIBDIR%|$(get_libdir)|g" "${FILESDIR}/boost.eselect-${PVR%-r*}" > "${ED}${mdir}/boost.eselect" || die "failed to install"

	sed -i \
		-e 's:\${ROOT}:${ROOT}'"${EPREFIX}"':g' \
		-e 's:\${ROOT}'"${EPREFIX}"'\${\(t\|includes\)}:${ROOT}${\1}:g' \
		"${ED}${mdir}/boost.eselect" || die

	keepdir /etc/eselect/boost
	keepdir /usr/share/boost-eselect/profiles
}
