# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-plugins/noscript/noscript-1.9.8.86.ebuild,v 1.3 2010/01/01 18:03:23 scarabeus Exp $

inherit mozextension multilib

DESCRIPTION="Restrict active contents in your web browser"
HOMEPAGE="http://noscript.net/"
SRC_URI="http://software.informaction.com/data/releases/${P}.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="
	|| (
		>=www-client/mozilla-firefox-1.5
		>=www-client/firefox-bin-1.5
		>=www-client/seamonkey-1.1
		>=www-client/seamonkey-bin-1.1
		>=www-client/icecat-3.5
	)"
DEPEND="${RDEPEND}"

S=${WORKDIR}

# NOTES:
# can also be used for Flock, MidBrowser, eMusic, Toolkit, Songbird, Fennec

src_unpack() {
	xpi_unpack "${P}".xpi
}

src_install() {
	local MOZILLA_FIVE_HOME
	mozillas=""

	if has_version '>=www-client/mozilla-firefox-1.5'; then
		MOZILLA_FIVE_HOME="${EPREFIX}/usr/$(get_libdir)/mozilla-firefox"
		xpi_install "${WORKDIR}/${P}"
		mozillas="$(best_version www-client/mozilla-firefox) ${mozillas}"
	fi
	if has_version '>=www-client/firefox-bin-1.5'; then
		MOZILLA_FIVE_HOME="${EPREFIX}/opt/firefox"
		xpi_install "${WORKDIR}/${P}"
		mozillas="$(best_version www-client/firefox-bin) ${mozillas}"
	fi
	if has_version '>=www-client/seamonkey-1.1'; then
		MOZILLA_FIVE_HOME="${EPREFIX}/usr/$(get_libdir)/seamonkey"
		xpi_install "${WORKDIR}/${P}"
		mozillas="$(best_version www-client/seamonkey) ${mozillas}"
	fi
	if has_version '>=www-client/seamonkey-bin-1.1'; then
		MOZILLA_FIVE_HOME="${EPREFIX}/opt/seamonkey"
		xpi_install "${WORKDIR}/${P}"
		mozillas="$(best_version www-client/seamonkey-bin) ${mozillas}"
	fi
	if has_version '>=www-client/icecat-3.5'; then
		MOZILLA_FIVE_HOME="${EPREFIX}/usr/$(get_libdir)/icecat"
		xpi_install "${WORKDIR}/${P}"
		mozillas="$(best_version www-client/icecat) ${mozillas}"
	fi

}

pkg_postinst() {
	elog "NoScript has been installed for the following packages:"
	for i in ${mozillas}; do
		elog "  $i"
	done
	elog
	elog "After installing other mozilla ebuilds, if you want to use noscript with them"
	elog "reinstall www-plugins/noscript"
}
