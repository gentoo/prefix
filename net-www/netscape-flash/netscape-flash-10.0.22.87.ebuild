# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-www/netscape-flash/netscape-flash-10.0.22.87.ebuild,v 1.4 2009/03/08 14:39:36 maekke Exp $

EAPI=1
inherit nsplugins rpm multilib

MY_32B_URI="http://fpdownload.macromedia.com/get/flashplayer/current/flash-plugin-${PV}-release.i386.rpm"
MY_64B_URI="http://download.macromedia.com/pub/labs/flashplayer10/libflashplayer-${PV}.linux-x86_64.so.tar.gz"

DESCRIPTION="Adobe Flash Player"
SRC_URI="x86? ( ${MY_32B_URI} )
amd64? ( ${MY_64B_URI}
	multilib? ( 32bit? (
		${MY_32B_URI} mirror://gentoo/flash-libcompat-0.2.tar.bz2
	) )
)"
HOMEPAGE="http://www.adobe.com/"
IUSE="multilib +32bit"
SLOT="0"

KEYWORDS="~amd64-linux ~x86-linux"
LICENSE="AdobeFlash-10"
RESTRICT="strip mirror"

S="${WORKDIR}"

RDEPEND="x11-libs/gtk+:2
	media-libs/fontconfig
	dev-libs/nss
	net-misc/curl
	!prefix? ( >=sys-libs/glibc-2.4 )
	|| ( media-fonts/freefont-ttf media-fonts/corefonts )
	amd64? (
		multilib? ( 32bit? (
			app-emulation/emul-linux-x86-baselibs
			app-emulation/emul-linux-x86-gtklibs
			app-emulation/emul-linux-x86-soundlibs
			app-emulation/emul-linux-x86-xlibs
		) )
	)
"

# Our new flash-libcompat suffers from the same EXESTACK problem as libcrypto
# from app-text/acroread, so tell QA to ignore it.
# Apparently the flash library itself also suffers from this issue
QA_EXECSTACK="opt/flash-libcompat/libcrypto.so.0.9.7
	opt/netscape/plugins32/libflashplayer.so
	opt/netscape/plugins/libflashplayer.so"

src_install() {
	# 32b RPM has things hidden in funny places
	use x86 && pushd "${S}/usr/lib/flash-plugin"

	exeinto /opt/netscape/plugins
	doexe libflashplayer.so
	inst_plugin /opt/netscape/plugins/libflashplayer.so

	use x86 && popd "${S}/usr/lib/flash-plugin"

	# 64b tarball has no readme file.
	use x86 && dodoc "${S}/usr/share/doc/flash-plugin-${PV}/readme.txt"

	if use amd64 && has_multilib_profile && use 32bit; then
		oldabi="${ABI}"
		ABI="x86"

		# 32b plugin
		pushd "${S}/usr/lib/flash-plugin"
			exeinto /opt/netscape/plugins32/
			doexe libflashplayer.so
			inst_plugin /opt/netscape/plugins32/libflashplayer.so
			dodoc "${S}/usr/share/doc/flash-plugin-${PV}/readme.txt"
		popd

		# 32b library compatibility:
		#
		# libcurl and libnss are not currently available in any emul-linux-x86
		# packages, so for amd64 we provide these snarfed out of other binary
		# packages.  libcurl and its ssl dependencies come from
		# app-text/acroread; libnss and its friends come from
		# net-libs/xulrunner-bin
		exeinto /opt/flash-libcompat
		pushd "${WORKDIR}/flash-libcompat-0.2/"
			doexe *
		popd
		echo 'LDPATH="'"${EPREFIX}"'/opt/flash-libcompat"' > 99flash-libcompat
		doenvd 99flash-libcompat

		ABI="${oldabi}"
	fi

	# The magic config file!
	insinto "/etc/adobe"
	doins "${FILESDIR}/mms.cfg"
}

pkg_postinst() {
	if use amd64 && has_version 'net-www/nspluginwrapper'; then
		# TODO: Perhaps parse the output of 'nspluginwrapper -l'
		#       However, the 64b flash plugin makes 'nspluginwrapper -l' segfault.
		local FLASH_WRAPPER="${EROOT}/usr/lib64/nsbrowser/plugins/npwrapper.libflashplayer.so"
		if [[ -f ${FLASH_WRAPPER} ]]; then
			einfo "Removing duplicate 32-bit plugin wrapper: Native 64-bit plugin installed"
			nspluginwrapper -r ${FLASH_WRAPPER}
		fi
	fi

	ewarn "Flash player is closed-source, with a long history of security"
	ewarn "issues.  Please consider only running flash applets you know to"
	ewarn "be safe.  The 'flashblock' extension may help for mozilla users:"
	ewarn "  https://addons.mozilla.org/en-US/firefox/addon/433"

	if has_version 'kde-base/konqueror'; then
		elog "Konqueror users - You may need to follow the instructions here:"
		elog "  http://www.gentoo.org/proj/en/desktop/kde/kde-flash.xml"
		elog "For flash to work with your browser."
	fi
}
