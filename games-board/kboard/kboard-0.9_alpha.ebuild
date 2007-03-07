# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit games toolchain-funcs

MY_P="kboard-alpha-0.9b"
DESCRIPTION="graphical interface for playing Chess, Shogi and variants"
HOMEPAGE="http://kboard.sourceforge.net"
SRC_URI="mirror://sourceforge/kboard/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-macos"
IUSE=""

DEPEND="=x11-libs/qt-4*
	dev-libs/boost
	dev-lang/lua
	dev-util/cmake"
RDEPEND="${DEPEND}"
S=${WORKDIR}/${MY_P}

src_compile() {
	sed -i -e "s:execve.*::" src/crash.cpp
	cmake \
		-D CMAKE_CXX_COMPILER:FILEPATH="$(tc-getCXX)" \
		-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
		-D CMAKE_C_COMPILER:FILEPATH="$(tc-getCC)" \
		-DCMAKE_C_FLAGS="${CFLAGS}" \
		-DCMAKE_INSTALL_PREFIX="${GAMES_PREFIX}" \
		-DDATA_INSTALL_DIR="${GAMES_DATADIR}" \
		-DQT_PNG_LIBRARY=${EPREFIX}/usr/lib/libpng12.dylib \
		. || die "ecmake failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	rm ${ED}/usr/games/share/kboard/themes/Pieces/AlphaTTF/gradient*
	dodoc AUTHORS BUGS CHANGELOG INSTALL README RELEASE TODO
#	prepgamesdirs
}
