# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-www/netscape-flash/netscape-flash-9.0.48.0.ebuild,v 1.3 2007/07/15 04:40:21 mr_bones_ Exp $

EAPI="prefix"

inherit nsplugins

MY_P="install_flash_player_9_linux"
MY_PD="flash_player_9_linux_dev"

DESCRIPTION="Adobe Flash Player"
SRC_URI="!debug? ( http://fpdownload.macromedia.com/get/flashplayer/current/${MY_P}.tar.gz )
	http://fpdownload.macromedia.com/pub/flashplayer/updaters/9/${MY_PD}.tar.gz"
HOMEPAGE="http://www.adobe.com/"
IUSE="debug"
SLOT="0"

KEYWORDS="~amd64 ~x86"
LICENSE="AdobeFlash-9.0.31.0"
S=${WORKDIR}/install_flash_player_9_linux
RESTRICT="strip mirror"

S=${WORKDIR}

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

src_unpack() {
	unpack ${A}

	cd ${S}
	if use debug; then
		unpack ./${MY_PD}/plugin/debugger/${MY_P}.tar.gz
		unpack ./${MY_PD}/standalone/debugger/flashplayer.tar.gz
	else
		unpack ./${MY_PD}/standalone/release/flashplayer.tar.gz
	fi
}

src_install() {
	dobin flashplayer

	dodoc ${MY_PD}/README

	cd ${MY_P}
	exeinto /opt/netscape/plugins
	doexe libflashplayer.so
	insinto /opt/netscape/plugins
	doins flashplayer.xpt

	inst_plugin /opt/netscape/plugins/libflashplayer.so
	inst_plugin /opt/netscape/plugins/flashplayer.xpt
}

pkg_postinst() {
	if use debug ; then
		elog "You are installing content debugger version of the package."
		elog "This is NOT intended for normal use!"
	fi
}
