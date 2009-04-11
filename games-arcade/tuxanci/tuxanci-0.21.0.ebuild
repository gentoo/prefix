# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-arcade/tuxanci/tuxanci-0.21.0.ebuild,v 1.7 2009/02/08 10:39:06 scarabeus Exp $

EAPI=2

inherit eutils cmake-utils games

DESCRIPTION="Tuxanci is first cushion shooter inspired by game Bulanci."
HOMEPAGE="http://www.tuxanci.org/"
SRC_URI="http://download.${PN}.org/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="alsa debug dedicated nls"
# alsa is used only when building client

RDEPEND="!dedicated? (
			>=media-libs/libsdl-1.2.10[X]
			>=media-libs/sdl-ttf-2.0.7[X]
			>=media-libs/sdl-image-1.2.6-r1[png]
			alsa? (
				>=media-libs/sdl-mixer-1.2.7[vorbis]
			)
		)
	dev-libs/zziplib[sdl]"
DEPEND="${RDEPEND}
	>=dev-util/cmake-2.6.0
	nls? ( sys-devel/gettext )"

src_configure() {
	local mycmakeargs
	use alsa || mycmakeargs="${mycmakeargs} -DNO_Audio=1"
	use debug && mycmakeargs="${mycmakeargs} -DDebug=1"
	use dedicated && mycmakeargs="${mycmakeargs} -DServer=1"
	use nls && mycmakeargs="${mycmakeargs} -DNLS=1"
	# This cant be quoted due to cmake nature.
	# Read as: quote it and it wont compile.
	mycmakeargs="${mycmakeargs} -DCMAKE_INSTALL_PREFIX=${GAMES_PREFIX}
		-DCMAKE_DATA_PATH=${GAMES_DATADIR}
		-DCMAKE_LOCALE_PATH=${GAMES_DATADIR_BASE}/locale/
		-DCMAKE_DOC_PATH=${GAMES_DATADIR_BASE}/doc/
		-DCMAKE_CONF_PATH=${GAMES_SYSCONFDIR} -DLIB_INSTALL_DIR=$(games_get_libdir)
		-DCMAKE_BUILD_TYPE=Release"
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	local MY_PN
	use dedicated && MY_PN=${PN}-server || MY_PN=${PN}

	cmake-utils_src_install
	dosym "${GAMES_BINDIR}"/${MY_PN}-${PV} "${GAMES_BINDIR}"/${MY_PN}
	doicon data/${PN}.svg
	# we compile our desktop file
	domenu data/${PN}.desktop
	prepgamesdirs
}
