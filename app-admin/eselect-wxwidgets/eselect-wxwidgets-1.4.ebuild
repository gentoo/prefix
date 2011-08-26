# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-wxwidgets/eselect-wxwidgets-1.4.ebuild,v 1.7 2011/01/12 13:40:46 xarthisius Exp $

inherit eutils prefix

WXWRAP_VER=1.3
WXESELECT_VER=1.4

DESCRIPTION="Eselect module and wrappers for wxWidgets"
HOMEPAGE="http://www.gentoo.org"
SRC_URI="mirror://gentoo/wxwidgets.eselect-${WXESELECT_VER}.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND="!<=x11-libs/wxGTK-2.6.4.0-r2"
RDEPEND=">=app-admin/eselect-1.2.3"

S=${WORKDIR}

src_unpack() {
	unpack ${A}
	cd "${S}"
	cp "${FILESDIR}"/wx-config-${WXWRAP_VER} "${T}"/
	cp "${FILESDIR}"/wxrc-${WXWRAP_VER} "${T}"/
	cd "${T}"
	eprefixify wx-config-${WXWRAP_VER} wxrc-${WXWRAP_VER}
}

src_install() {
	insinto /usr/share/eselect/modules
	newins wxwidgets.eselect-${WXESELECT_VER} wxwidgets.eselect \
		|| die "Failed installing module"

	insinto /usr/share/aclocal
	newins "${FILESDIR}"/wxwin.m4-2.9 wxwin.m4 || die "Failed installing m4"

	newbin "${T}"/wx-config-${WXWRAP_VER} wx-config \
		|| die "Failed installing wx-config"
	newbin "${T}"/wxrc-${WXWRAP_VER} wxrc \
		|| die "Failed installing wxrc"

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
