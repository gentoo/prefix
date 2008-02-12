# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/jed/jed-0.99.16-r2.ebuild,v 1.22 2007/10/10 06:53:13 opfer Exp $

EAPI="prefix"

inherit eutils

P0=${PN}-0.99-16
S=${WORKDIR}/${P0}
DESCRIPTION="Console S-Lang-based editor"
HOMEPAGE="http://www.jedsoft.org/jed/"
SRC_URI="ftp://ftp.uni-stuttgart.de/pub/unix/misc/slang/jed/v0.99/${P0}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="X gpm truetype"

RDEPEND="=sys-libs/slang-1.4*
	X? ( x11-libs/libX11 x11-libs/libXext x11-libs/libXrender )
	gpm? ( sys-libs/gpm )
	X? ( truetype? ( || ( x11-libs/libXft virtual/xft )
					>=media-libs/freetype-2.0 ) )"
DEPEND="${RDEPEND}
	>=sys-apps/sed-4"

src_unpack() {
	unpack ${A}
	cd "${S}"; epatch "${FILESDIR}/${P}-jed.info.patch"
	[[ ${CHOST} == *-darwin* ]]	&& epatch "${FILESDIR}/${P}-darwin.patch"
}

src_compile() {
	export JED_ROOT="${EPREFIX}"/usr/share/jed

	./configure	--host=${CHOST} \
		--prefix="${JED_ROOT}" \
		--bindir="${EPREFIX}"/usr/bin \
		--mandir="${EPREFIX}"/usr/share/man || die

	if use gpm ; then
		cd src
		sed -i	-e 's/#MOUSEFLAGS/MOUSEFLAGS/' \
			-e 's/#MOUSELIB/MOUSELIB/' \
			-e 's/#GPMMOUSEO/GPMMOUSEO/' \
			-e 's/#OBJGPMMOUSEO/OBJGPMMOUSEO/' \
			Makefile
		cd "${S}"
	fi

	if use X && use truetype ; then
	   cd src
	   sed -i -e 's/#XRENDERFONTLIBS/XRENDERFONTLIBS/' Makefile
	   sed -i -e 's/^CONFIG_H = config.h/xterm_C_FLAGS = `freetype-config --cflags`\nCONFIG_H = config.h/' Makefile
	   sed -i -e 's/#define XJED_HAS_XRENDERFONT 0/#define XJED_HAS_XRENDERFONT 1/' jed-feat.h
	   cd "${S}"
	fi

	make clean || die

	emake || die

	if use X ; then
		emake xjed || die
	fi
}

src_install() {
	# make install in ${S} claims everything is up-to-date,
	# so we manually cd ${S}/src before installing
	cd "${S}/src"
	make DESTDIR="${D}" install || die

	cd "${S}/doc"
	cp README AUTHORS

	cd "${S}"
	dodoc INSTALL INSTALL.unx README doc/AUTHORS doc/manual/jed.tex

	cd "${S}/info"
	rm info.info
	epatch "${FILESDIR}/jed.info.diff"
	cd "${S}"

	insinto /usr/share/info
	doins info/*

	insinto /etc
	doins lib/jed.conf

	# replace IDE mode with EMACS mode
	sed -i -e 's/\(_Jed_Default_Emulation = \).*/\1"emacs";/' "${ED}/etc/jed.conf" || die "patching jed.conf failed"

	cd "${ED}"
	rm -rf usr/share/jed/info
	# can't rm usr/share/jed/doc -- used internally by jed/xjed
}
