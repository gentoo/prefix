# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-www/netscape-flash/netscape-flash-9.0.60.0_beta082207.ebuild,v 1.2 2007/09/06 15:45:57 jer Exp $

EAPI="prefix"

inherit nsplugins versionator

MY_BETADATE=$(get_version_component_range 5)
MY_PV=${MY_BETADATE:4}
MY_P="install_flash_player_9_linux"

DESCRIPTION="Adobe Flash Player"
SRC_URI="http://download.macromedia.com/pub/labs/flashplayer9_update/flashplayer9_install_linux_${MY_PV}.tar.gz"
HOMEPAGE="http://labs.adobe.com/technologies/flashplayer9/"
IUSE=""
SLOT="0"

KEYWORDS="~amd64 ~x86"
LICENSE="AdobeFlash-9.0.31.0"
S=${WORKDIR}/${MY_P}
RESTRICT="strip mirror"

DEPEND="amd64? ( app-emulation/emul-linux-x86-baselibs
			app-emulation/emul-linux-x86-gtklibs
			app-emulation/emul-linux-x86-soundlibs
			 app-emulation/emul-linux-x86-xlibs )
	x86? ( x11-libs/libXext
		x11-libs/libX11
		x11-libs/libXt
		=x11-libs/gtk+-2*
		media-libs/freetype
		media-libs/fontconfig )"

pkg_setup() {
	# This is a binary x86 package => ABI=x86
	# Please keep this in future versions
	# Danny van Dyk <kugelfang@gentoo.org> 2005/03/26
	has_multilib_profile && ABI="x86"
}

src_install() {
	cd ${MY_P}
	exeinto /opt/netscape/plugins
	doexe libflashplayer.so
	inst_plugin /opt/netscape/plugins/libflashplayer.so
}

pkg_postinst() {
	elog "This is a trimmed-down BETA version of flashplayer."
	elog "It only includes the netscape plugin, not the standalone"
	elog "'flashplayer' executable.  If you need the standalone player,"
	elog "you must downgrade to the previous version."
	ewarn "This BETA version has a number of known bugs (so far minor),"
	ewarn "which is why it is package masked.  You have been warned."
}
