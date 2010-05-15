# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/freetype/freetype-2.3.11.ebuild,v 1.5 2010/04/13 21:36:01 hwoarang Exp $

inherit eutils flag-o-matic autotools

DESCRIPTION="A high-quality and portable font engine"
HOMEPAGE="http://www.freetype.org/"
SRC_URI="mirror://sourceforge/freetype/${P/_/}.tar.bz2
	utils?	( mirror://sourceforge/freetype/ft2demos-${PV}.tar.bz2 )
	doc?	( mirror://sourceforge/freetype/${PN}-doc-${PV}.tar.bz2 )"

LICENSE="FTL GPL-2"
SLOT="2"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="X bindist debug doc utils fontforge"

DEPEND="sys-libs/zlib
	X?	( x11-libs/libX11
		  x11-libs/libXau
		  x11-libs/libXdmcp )"

# We also need a recent fontconfig version to prevent segfaults. #166029
# July 3 2007 dirtyepic
RDEPEND="${DEPEND}
		!<media-libs/fontconfig-2.3.2-r2"

src_unpack() {
	unpack ${A}
	cd "${S}"

	enable_option() {
		sed -i -e "/#define $1/a #define $1" \
			include/freetype/config/ftoption.h \
			|| die "unable to enable option $1"
	}

	disable_option() {
		sed -i -e "/#define $1/ { s:^:/*:; s:$:*/: }" \
			include/freetype/config/ftoption.h \
			|| die "unable to disable option $1"
	}

	if ! use bindist; then
		# Bytecodes and subpixel hinting supports are patented
		# in United States; for safety, disable them while building
		# binaries, so that no risky code is distributed.
		# See http://freetype.org/patents.html

		enable_option FT_CONFIG_OPTION_SUBPIXEL_RENDERING
		enable_option TT_CONFIG_OPTION_BYTECODE_INTERPRETER
		disable_option TT_CONFIG_OPTION_UNPATENTED_HINTING
	fi

	if use debug; then
		enable_option FT_DEBUG_LEVEL_ERROR
		enable_option FT_DEBUG_MEMORY
	fi

	enable_option FT_CONFIG_OPTION_INCREMENTAL
	disable_option FT_CONFIG_OPTION_OLD_INTERNALS

	epatch "${FILESDIR}"/${PN}-2.3.2-enable-valid.patch

	if use utils; then
		cd "${WORKDIR}"/ft2demos-${PV}
		sed -i -e "s:\.\.\/freetype2$:../freetype-${PV}:" Makefile

		# Disable tests needing X11 when USE="-X". (bug #177597)
		if ! use X; then
			sed -i -e "/EXES\ +=\ ftview/ s:^:#:" Makefile
		fi
	fi

	# required eautoreconf to get patched libtool on _all_ platforms,
	# for the library search to function propperly.
	cd "${S}"/builds/unix
	eautoreconf
	epunt_cxx
}

src_compile() {
	append-flags -fno-strict-aliasing

	type -P gmake &> /dev/null && export GNUMAKE=gmake
	econf
	emake || die "emake failed"

	if use utils; then
		cd "${WORKDIR}"/ft2demos-${PV}
		emake || die "ft2demos emake failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc ChangeLog README
	dodoc docs/{CHANGES,CUSTOMIZE,DEBUG,*.txt,PATENTS,TODO}

	use doc && dohtml -r docs/*

	if use utils; then
		rm "${WORKDIR}"/ft2demos-${PV}/bin/README
		for ft2demo in ../ft2demos-${PV}/bin/*; do
			./builds/unix/libtool --mode=install $(type -P install) -m 755 "$ft2demo" \
				"${ED}"/usr/bin
		done
	fi
	# Probably fontforge needs less but this way makes things simplier...
	if use fontforge; then
		einfo "Installing internal headers required for fontforge"
		find src/truetype include/freetype/internal -name '*.h' | \
		while read header; do
			mkdir -p "${ED}/usr/include/freetype2/internal4fontforge/$(dirname ${header})"
			cp ${header} "${ED}/usr/include/freetype2/internal4fontforge/$(dirname ${header})"
		done
	fi
}

pkg_postinst() {
	echo
	elog "The utilities and demos previously bundled with freetype are now"
	elog "optional.  Enable the utils USE flag if you would like them"
	elog "to be installed."
	echo
}
