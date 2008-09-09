# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-www/netscape-flash/netscape-flash-10_beta20080811.ebuild,v 1.3 2008/09/09 03:43:10 lack Exp $

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
SRC_URI="http://download.macromedia.com/pub/labs/flashplayer${MV}/flashplayer${MV}_install_linux_${BV}.tar.gz
mirror://gentoo/flash-libcompat-0.1.tar.bz2"
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
			|| ( net-libs/xulrunner-bin www-client/mozilla-firefox-bin ) )
	x86? ( x11-libs/libXext
		x11-libs/libX11
		x11-libs/libXt
		=x11-libs/gtk+-2*
		media-libs/freetype
		media-libs/fontconfig
		dev-libs/nss
		net-misc/curl
		>=sys-libs/glibc-2.4 )
	media-fonts/corefonts"

# Our new flash-libcompat suffers from the same EXESTACK problem as libcrypto
# from app-text/acroread, so tell QA to ignore it:
QA_EXECSTACK="opt/flash-libcompat/libcrypto.so.0.9.7"

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

	# This version especially is ugly in that it hard-requires libcurl.so.3,
	# libcrypto.so.0.9.7 and libssl.so.0.9.7, so we just provide our own 32-bit
	# binary version of these libs.
	exeinto /opt/flash-libcompat
	pushd "${WORKDIR}/flash-libcompat-0.1/"
	doexe *
	popd
	echo 'LDPATH="/opt/flash-libcompat"' > 99flash-libcompat
	doenvd 99flash-libcompat

	# Apparently the next release will dynamically check for libcurl.so.4 and
	# libcurl.so.3 (and maybe the SSLs too, I hope) , so this will be slightly
	# less ugly (especially if we can get libcurl into one of the emul-linux-x86
	# packages)

	# The magic config file!
	insinto "/etc/adobe"
	doins "${FILESDIR}/mms.cfg"
}

pkg_postinst() {
	ewarn "Flash player is closed-source, with a long history of security"
	ewarn "issues.  Please consider only running flash applets you know to"
	ewarn "be safe.  The firefox 'flashblock' extension may help:"
	ewarn "  https://addons.mozilla.org/en-US/firefox/addon/433"
	echo
	ewarn "Furthermore, <www-client/mozilla-firefox-3.0.2 is known to crash"
	ewarn "with the new 'Windowless' (transparent) mode.  To disable this and"
	ewarn "avoid the crashes, set 'WindowlessDisable = 1' in /etc/adobe/mms.cfg"
}
