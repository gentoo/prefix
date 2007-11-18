# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/jed/jed-0.99.18.ebuild,v 1.4 2007/11/16 16:53:53 fmccor Exp $

EAPI="prefix"

inherit eutils versionator

MY_PV=$(replace_version_separator 2 '-')
MY_P=${PN}-${MY_PV}
S=${WORKDIR}/${MY_P}
DESCRIPTION="Console S-Lang-based editor"
HOMEPAGE="http://www.jedsoft.org/jed/"
SRC_URI="ftp://space.mit.edu/pub/davis/jed/v0.99/${MY_P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-macos"
IUSE="X gpm truetype"

RDEPEND="=sys-libs/slang-2*
	X? ( x11-libs/libX11 x11-libs/libXext x11-libs/libXrender )
	X? ( truetype? ( || ( x11-libs/libXft virtual/xft )
					>=media-libs/freetype-2.0 ) )
	gpm? ( sys-libs/gpm )"
DEPEND="${RDEPEND}
	>=sys-apps/sed-4"

src_unpack() {
	unpack ${A}

	# Gennto slotted slang-2
	cd "${S}"
	sed -e 's:-lslang:-lslang-2:g' -i src/Makefile.in
	sed -e 's:libslang:libslang-2:g' -i configure

	#cd ${S}; epatch ${FILESDIR}/${P}-jed.info.patch
	[[ ${CHOST} == *-darwin* ]]	&& epatch "${FILESDIR}/${P}-darwin.patch"
}

src_compile() {
	export JED_ROOT="${EPREFIX}"/usr/share/jed

	./configure	--host=${CHOST} \
		--prefix="${JED_ROOT}" \
		--bindir="${EPREFIX}"/usr/bin \
		--mandir="${EPREFIX}"/usr/share/man \
		--with-slanginc="${EPREFIX}"/usr/include/slang-2 || die

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
	#epatch ${FILESDIR}/jed.info.diff
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
