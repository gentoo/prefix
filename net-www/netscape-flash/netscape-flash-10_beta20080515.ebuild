# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-www/netscape-flash/netscape-flash-10_beta20080515.ebuild,v 1.1 2008/05/15 14:35:11 lack Exp $

EAPI="prefix"

inherit nsplugins versionator

MV=$(get_major_version)

# Excellent, Adobe uses that unsortable though surprisingly popular date
# convention "MMDDYY", so build that out of a proper "YYYYMMDD" beta version
# component:
BETA=$(get_version_component_range 2)
BETA=${BETA#beta}
BV=${BETA:4:2}${BETA:6:2}${BETA:2:2}

DESCRIPTION="Adobe Flash Player"
SRC_URI="http://download.macromedia.com/pub/labs/flashplayer${MV}/flashplayer${MV}_install_linux_${BV}.tar.gz"
HOMEPAGE="http://www.adobe.com/"
IUSE=""
SLOT="0"

KEYWORDS="~amd64-linux ~x86-linux"
LICENSE="AdobeFlash-9.0.31.0"
RESTRICT="strip mirror"

S="${WORKDIR}/install_flash_player_${MV}_linux"

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
	exeinto /opt/netscape/plugins
	doexe libflashplayer.so
	inst_plugin /opt/netscape/plugins/libflashplayer.so
}
