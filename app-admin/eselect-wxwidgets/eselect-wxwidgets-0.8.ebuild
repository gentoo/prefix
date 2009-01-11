# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-wxwidgets/eselect-wxwidgets-0.8.ebuild,v 1.9 2008/07/16 12:46:08 aballier Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Manage the system default for wxWidgets packages."
HOMEPAGE="http://www.gentoo.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND="!<=x11-libs/wxGTK-2.6.4.0-r2"
RDEPEND="app-admin/eselect"

src_unpack() {
	cp "${FILESDIR}"/wx-config-0.7 "${T}"/
	cp "${FILESDIR}"/wxrc-0.7 "${T}"/
	cp "${FILESDIR}"/wxwidgets.eselect-${PV} "${T}"/
	cd "${T}"
	epatch "${FILESDIR}"/wx-config-0.7-prefix.patch
	epatch "${FILESDIR}"/wxrc-0.7-prefix.patch
	eprefixify wx-config-0.7 wxrc-0.7 wxwidgets.eselect-${PV}
}

src_install() {
	insinto /usr/share/eselect/modules
	newins "${T}"/wxwidgets.eselect-${PV} wxwidgets.eselect \
		|| die "Failed installing module"

	insinto /usr/share/aclocal
	doins "${FILESDIR}"/wxwin.m4

	newbin "${T}"/wx-config-0.7 wx-config
	newbin "${T}"/wxrc-0.7 wxrc

	keepdir /var/lib/wxwidgets
	keepdir /usr/share/bakefile/presets
}

pkg_postinst() {
	if [[ ! -e ${EROOT}/var/lib/wxwidgets/current ]]; then
		echo 'WXCONFIG="none"' > "${EROOT}"/var/lib/wxwidgets/current
	fi

	echo
	elog "By default your system wxWidgets profile is set to \"none\"."
	elog
	elog "You will need to select a profile using \`eselect wxwidgets\` to"
	elog "use wxGTK outside of portage.  If you do not plan on building"
	elog "packages or doing development work with wxGTK outside of portage"
	elog "then you can safely leave this set to \"none\"."
	echo
}
