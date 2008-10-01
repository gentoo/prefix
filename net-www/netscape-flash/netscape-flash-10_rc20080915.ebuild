# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-www/netscape-flash/netscape-flash-10_rc20080915.ebuild,v 1.1 2008/09/17 16:14:34 lack Exp $

EAPI="prefix"

inherit nsplugins versionator

MV=$(get_major_version)

# Excellent, Adobe uses that unsortable though surprisingly popular date
# convention "MMDDYY", so build that out of a proper "YYYYMMDD" beta version
# component:
BETA=$(get_version_component_range 2)
BETA=${BETA#rc}
BV=${BETA:4:2}${BETA:6:2}${BETA:2:2}

DESCRIPTION="Adobe Flash Player"
SRC_URI="http://download.macromedia.com/pub/labs/flashplayer${MV}/flashplayer${MV}_install_linux_${BV}.tar.gz
amd64? ( mirror://gentoo/flash-libcompat-0.2.tar.bz2 )"
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
		media-libs/fontconfig
		dev-libs/nss
		net-misc/curl
		!prefix? ( >=sys-libs/glibc-2.4 ) )
	media-fonts/corefonts"

# Our new flash-libcompat suffers from the same EXESTACK problem as libcrypto
# from app-text/acroread, so tell QA to ignore it.
# Apparently the flash library itseld also suffers from this issue
QA_EXECSTACK="opt/flash-libcompat/libcrypto.so.0.9.7
	opt/netscape/plugins/libflashplayer.so"

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

	# libcurl and libnss are not currently available in any emul-linux-x86
	# packages, so for amd64 we provide these snarfed out of other binary
	# packages.  libcurl and its ssl dependencies come from app-text/acroread;
	# libnss and its friends come from net-libs/xulrunner-bin
	if use amd64; then
		exeinto /opt/flash-libcompat
		pushd "${WORKDIR}/flash-libcompat-0.2/"
		doexe *
		popd
		echo 'LDPATH="/opt/flash-libcompat"' > 99flash-libcompat
		doenvd 99flash-libcompat
	fi

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
