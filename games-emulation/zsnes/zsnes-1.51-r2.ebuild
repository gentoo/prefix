# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-emulation/zsnes/zsnes-1.51-r2.ebuild,v 1.6 2009/04/14 09:42:56 armin76 Exp $

inherit eutils autotools flag-o-matic toolchain-funcs multilib games

DESCRIPTION="SNES (Super Nintendo) emulator that uses x86 assembly"
HOMEPAGE="http://www.zsnes.com/ http://ipherswipsite.com/zsnes/"
SRC_URI="mirror://sourceforge/zsnes/${PN}${PV//./}src.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="ao custom-cflags opengl png"

RDEPEND="media-libs/libsdl
	>=sys-libs/zlib-1.2.3-r1
	amd64? ( >=app-emulation/emul-linux-x86-sdl-10.1 )
	ao? ( media-libs/libao )
	opengl? ( virtual/opengl )
	png? ( media-libs/libpng )"
DEPEND="${RDEPEND}
	dev-lang/nasm
	amd64? ( >=sys-apps/portage-2.1 )"

S=${WORKDIR}/${PN}_${PV//./_}/src

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fixing compilation without libpng installed
	epatch "${FILESDIR}"/${P}-libpng.patch
	# Fix bug #186111
	epatch "${FILESDIR}"/${P}-archopt-july-23-update.patch
	epatch "${FILESDIR}"/${P}-gcc43.patch
	# Fix bug #214697
	epatch "${FILESDIR}"/${P}-libao-thread.patch
	# Fix bug #170108
	epatch "${FILESDIR}"/${P}-depbuild.patch
	# Fix bug #260247
	epatch "${FILESDIR}"/${P}-CC-quotes.patch

	# Remove hardcoded CFLAGS and LDFLAGS
	sed -i \
		-e '/^CFLAGS=.*local/s:-pipe.*:-Wall -I.":' \
		-e '/^LDFLAGS=.*local/d' \
		-e '/\w*CFLAGS=.*fomit/s:-O3.*$STRIP::' \
		configure.in \
		|| die "sed failed"
	eautoreconf
}

src_compile() {
	tc-export CC
	use amd64 && multilib_toolchain_setup x86
	use custom-cflags || strip-flags

	append-flags -U_FORTIFY_SOURCE	#257963

	egamesconf \
		$(use_enable ao libao) \
		$(use_enable png libpng) \
		$(use_enable opengl) \
		--disable-debug \
		--disable-cpucheck \
		--enable-release \
		force_arch=no \
		|| die
	emake makefile.dep || die "emake makefile.dep failed"
	emake || die "emake failed"
}

src_install() {
	dogamesbin zsnes || die "dogamesbin failed"
	newman linux/zsnes.1 zsnes.6
	dodoc ../docs/{readme.1st,*.txt,README.LINUX}
	dodoc ../docs/readme.txt/*
	dohtml -r ../docs/readme.htm/*
	make_desktop_entry zsnes ZSNES
	newicon icons/48x48x32.png ${PN}.png
	prepgamesdirs
}
