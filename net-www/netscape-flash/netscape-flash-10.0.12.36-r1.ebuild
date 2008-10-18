# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-www/netscape-flash/netscape-flash-10.0.12.36-r1.ebuild,v 1.1 2008/10/17 20:03:57 lack Exp $

EAPI="prefix"

inherit nsplugins rpm

DESCRIPTION="Adobe Flash Player"
SRC_URI="http://fpdownload.macromedia.com/get/flashplayer/current/flash-plugin-${PV}-release.i386.rpm
amd64? ( mirror://gentoo/flash-libcompat-0.2.tar.bz2 )"
HOMEPAGE="http://www.adobe.com/"
IUSE=""
SLOT="0"

KEYWORDS="~amd64-linux ~x86-linux"
LICENSE="AdobeFlash-10"
RESTRICT="strip mirror"

S="${WORKDIR}"

RDEPEND="amd64? ( app-emulation/emul-linux-x86-baselibs
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
# Apparently the flash library itself also suffers from this issue
QA_EXECSTACK="opt/flash-libcompat/libcrypto.so.0.9.7
	opt/netscape/plugins/libflashplayer.so"

pkg_setup() {
	# This is a binary x86 package => ABI=x86
	# Please keep this in future versions
	# Danny van Dyk <kugelfang@gentoo.org> 2005/03/26
	has_multilib_profile && ABI="x86"
}

src_install() {
	pushd "${S}/usr/lib/flash-plugin"
	exeinto /opt/netscape/plugins
	doexe libflashplayer.so
	inst_plugin /opt/netscape/plugins/libflashplayer.so
	popd

	pushd "${S}/usr/share/doc/flash-plugin-${PV}/"
	dodoc readme.txt
	popd

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
	ewarn "be safe."

	if has_version 'www-client/mozilla-firefox'; then
		elog "The firefox 'flashblock' extension may help:"
		elog "  https://addons.mozilla.org/en-US/firefox/addon/433"
	fi

	if has_version 'kde-base/konqueror'; then
		elog "Konqueror users:  You may need to follow the instructions here:"
		elog "  http://dev.gentoo.org/~lack/konqueror-flash.xml"
		elog "For flash to work with your browser."
	fi
}
