# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-www/netscape-flash/netscape-flash-10.0.20.7_alpha.ebuild,v 1.1 2008/11/17 16:00:46 lack Exp $

EAPI="prefix"

inherit nsplugins rpm

DESCRIPTION="Adobe Flash Player"
SRC_URI="http://download.macromedia.com/pub/labs/flashplayer10/libflashplayer-10.0.d20.7.linux-x86_64.so.tar.gz"
HOMEPAGE="http://www.adobe.com/"
IUSE=""
SLOT="0"

KEYWORDS="~amd64-linux ~x86-linux"
LICENSE="AdobeFlash-10"
RESTRICT="strip mirror"

S="${WORKDIR}"

RDEPEND="x11-libs/libXext
	x11-libs/libX11
	x11-libs/libXt
	=x11-libs/gtk+-2*
	media-libs/freetype
	media-libs/fontconfig
	dev-libs/nss
	net-misc/curl
	!prefix? ( >=sys-libs/glibc-2.4 )
	media-fonts/corefonts"

QA_EXECSTACK="opt/netscape/plugins/libflashplayer.so"

src_install() {
	exeinto /opt/netscape/plugins
	doexe libflashplayer.so
	inst_plugin /opt/netscape/plugins/libflashplayer.so

	# The magic config file!
	insinto "/etc/adobe"
	doins "${FILESDIR}/mms.cfg"
}

pkg_postinst() {
	ewarn "Flash player is closed-source, with a long history of security"
	ewarn "issues.  Please consider only running flash applets you know to"
	ewarn "be safe."

	if has_version 'www-client/mozilla-firefox' || \
	   has_version 'www-client/mozilla-firefox-bin'; then
		elog "The firefox 'flashblock' extension may help:"
		elog "  https://addons.mozilla.org/en-US/firefox/addon/433"
	fi

	if has_version 'kde-base/konqueror'; then
		elog "Konqueror users:  You may need to follow the instructions here:"
		elog "  http://dev.gentoo.org/~lack/konqueror-flash.xml"
		elog "For flash to work with your browser."
	fi
}
