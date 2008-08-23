# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-www/netscape-flash/netscape-flash-10_beta20080811.ebuild,v 1.1 2008/08/23 00:25:28 lack Exp $

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
			 app-emulation/emul-linux-x86-xlibs
			 net-libs/xulrunner-bin )
	x86? ( x11-libs/libXext
		x11-libs/libX11
		x11-libs/libXt
		=x11-libs/gtk+-2*
		media-libs/freetype
		media-libs/fontconfig
		dev-libs/nss
		net-misc/curl
		>=sys-libs/glibc-2.4 )
	app-text/acroread
	media-fonts/corefonts"

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

	# This version especially is ugly in that it hard-requires libcurl.so.3.  On
	# x86 systems, we could just symlink to libcurl.so.4, but by using acroread
	# to provide the needed libs we have a single solution that works for both
	# amd64 and x86, which I like marginally better.
	echo 'LDPATH="/opt/Adobe/Reader8/Reader/intellinux/lib"' > 99flash-10-libhack
	doenvd 99flash-10-libhack

	# Apparently the next release will dynamically check for libcurl.so.4 and
	# libcurl.so.3, so this will be much less ugly (especially if we can get
	# libcurl into one of the emul-linux-x86 packages).
}

pkg_postinst() {
	ewarn "Flash player is closed-source, with a long history of security"
	ewarn "issues.  Please consider only running flash applets you know to"
	ewarn "be safe.  The firefox 'flashblock' extension may help:"
	ewarn "  https://addons.mozilla.org/en-US/firefox/addon/433"
}
