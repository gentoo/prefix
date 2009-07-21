# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-wxwidgets/eselect-wxwidgets-1.1.ebuild,v 1.1 2009/07/19 02:56:08 dirtyepic Exp $

inherit eutils prefix

DESCRIPTION="Eselect module and wrappers for wxWidgets"
HOMEPAGE="http://www.gentoo.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND="!<=x11-libs/wxGTK-2.6.4.0-r2"
RDEPEND="app-admin/eselect"

WXWRAP_VER=1.1

src_unpack() {
	cp "${FILESDIR}"/wx-config-${WXWRAP_VER} "${T}"/
	cp "${FILESDIR}"/wxrc-${WXWRAP_VER} "${T}"/
	cp "${FILESDIR}"/wxwidgets.eselect-0.8 "${T}"/
	cd "${T}"
	eprefixify wx-config-${WXWRAP_VER} wxrc-${WXWRAP_VER} wxwidgets.eselect-0.8
}

src_install() {
	insinto /usr/share/eselect/modules
	newins "${T}"/wxwidgets.eselect-0.8 wxwidgets.eselect \
		|| die "Failed installing module"

	insinto /usr/share/aclocal
	doins "${FILESDIR}"/wxwin.m4

	newbin "${T}"/wx-config-${WXWRAP_VER} wx-config
	newbin "${T}"/wxrc-${WXWRAP_VER} wxrc

	keepdir /var/lib/wxwidgets
	keepdir /usr/share/bakefile/presets
}

pkg_postinst() {
	if [[ ! -e ${EROOT}/var/lib/wxwidgets/current ]]; then
		echo 'WXCONFIG="none"' > "${EROOT}"/var/lib/wxwidgets/current
	fi

	echo
	elog "By default the system wxWidgets profile is set to \"none\"."
	elog
	elog "It is unnecessary to change this unless you are doing development work"
	elog "with wxGTK outside of portage.  The package manager ignores the profile"
	elog "setting altogether."
	echo
}
