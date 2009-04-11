# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-emulation/snes9x/snes9x-1.51.ebuild,v 1.2 2008/02/09 06:22:47 mr_bones_ Exp $

# 3dfx support (glide) is disabled because it requires
# glide-v2 while we only provide glide-v3 in portage
# http://bugs.gentoo.org/show_bug.cgi?id=93097

inherit autotools eutils flag-o-matic multilib games

DESCRIPTION="Super Nintendo Entertainment System (SNES) emulator"
HOMEPAGE="http://www.snes9x.com/"
SRC_URI="http://files.ipherswipsite.com/snes9x/${P}-src.tar.bz2
	http://vincent.grigorieff.free.fr/snes9x/${P}-src.tar.bz2"

LICENSE="as-is GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE="debug dga joystick netplay opengl zlib"

RDEPEND="x11-libs/libXext
	dga? ( x11-libs/libXxf86dga
		x11-libs/libXxf86vm )
	media-libs/libpng
	amd64? ( app-emulation/emul-linux-x86-xlibs )
	opengl? ( virtual/opengl
		virtual/glu )"
DEPEND="${RDEPEND}
	x86? ( dev-lang/nasm )
	x11-proto/xextproto
	x11-proto/xproto
	dga? ( x11-proto/xf86dgaproto
		x11-proto/xf86vidmodeproto )"

S=${WORKDIR}/${P}-src

pkg_setup() {
	use amd64 && [[ -z ${NATIVE_AMD64_BUILD_PLZ} ]] && has_multilib_profile && ABI=x86
	games_pkg_setup
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i \
		-e 's:-lXext -lX11::' Makefile.in \
		|| die "sed failed"
	epatch \
		"${FILESDIR}"/${P}-build.patch \
		"${FILESDIR}"/${P}-config.patch \
		"${FILESDIR}"/${P}-opengl.patch \
		"${FILESDIR}"/${P}-x11.patch

	eautoconf
}

src_compile() {
	local vidconf
	local target
	local vid
	local nooffset

	append-ldflags -Wl,-z,noexecstack

	mkdir "${WORKDIR}"/mybins
	for vid in opengl fallback ; do
		if [[ ${vid} != "fallback" ]] ; then
			use ${vid} || continue
		fi
		cd "${S}"
		case ${vid} in
#			3dfx)
#				vidconf="--with-glide --without-opengl"
#				target=gsnes9x;;
			opengl)
				vidconf="--with-opengl --without-glide"
				target=osnes9x;;
			fallback)
				vidconf="--without-glide --without-opengl"
				target=snes9x;;
		esac
		# this stuff is ugly but hey the build process sucks ;)
		egamesconf \
			${vidconf} \
			$(use_with x86 assembler) \
			$(use_with joystick) \
			$(use_with debug debugger) \
			$(use_with zlib) \
			$(use_with dga extensions) \
			$(use_with netplay) \
			|| die
		# Makefile doesn't quite support parallel builds
		emake ${target} || die "making ${target}"
		mv ${target} "${WORKDIR}"/mybins/
		cd "${WORKDIR}"
		rm -r "${S}"
		src_unpack
	done
}

src_install() {
	dogamesbin "${WORKDIR}"/mybins/* || die "dogamesbin failed"
	dodoc doc/* unix/docs/*
	prepgamesdirs
	elog "Starting with version 1.50, snes9x's behavior is determined by a"
	elog "configuration file. See readme_unix.txt and snes9x.conf.default"
	elog "in /usr/share/doc/${PF} for details."
}
