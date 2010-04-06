# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/netpbm/netpbm-10.49.00.ebuild,v 1.2 2010/03/20 20:37:24 vapier Exp $

EAPI=1
inherit toolchain-funcs eutils multilib prefix

MAN_VER=10.33
DESCRIPTION="A set of utilities for converting to/from the netpbm (and related) formats"
HOMEPAGE="http://netpbm.sourceforge.net/"
SRC_URI="mirror://gentoo/${P}.tar.lzma
	mirror://gentoo/${PN}-${MAN_VER}-manpages.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="jbig jpeg jpeg2k png rle svga tiff X xml zlib"

RDEPEND="jpeg? ( >=media-libs/jpeg-7:0 )
	jpeg2k? ( media-libs/jasper )
	tiff? ( >=media-libs/tiff-3.5.5 )
	png? ( >=media-libs/libpng-1.2.1 )
	xml? ( dev-libs/libxml2 )
	zlib? ( sys-libs/zlib )
	svga? ( media-libs/svgalib )
	jbig? ( media-libs/jbigkit )
	rle? ( media-libs/urt )
	X? ( x11-libs/libX11 )"
DEPEND="${RDEPEND}
	sys-devel/flex
	app-arch/xz-utils"

maint_pkg_create() {
	local base="${EPREFIX}/usr/local/src"
	local srcdir="${base}/netpbm/release_number"
	if [[ -d ${srcdir} ]] ; then
		cd "${T}" || die

		ebegin "Exporting ${srcdir}/${PV} to netpbm-${PV}"
		svn export -q ${srcdir}/${PV} netpbm-${PV}
		eend $? || return 1

		ebegin "Creating netpbm-${PV}.tar.lzma"
		tar cf - netpbm-${PV} | lzma > netpbm-${PV}.tar.lzma
		eend $?

		einfo "Tarball now ready at: ${T}/netpbm-${PV}.tar.lzma"
	else
		einfo "You need to run:"
		einfo " cd ${base}"
		einfo " svn co https://netpbm.svn.sourceforge.net/svnroot/netpbm"
		die "need svn checkout dir"
	fi
}
pkg_setup() { [[ -n ${VAPIER_LOVES_YOU} && ! -e ${DISTDIR}/${P}.tar.lzma ]] && maint_pkg_create ; }

netpbm_libtype() {
	case ${CHOST} in
		*-darwin*) echo dylib;;
		*)         echo unixshared;;
	esac
}
netpbm_libsuffix() {
	local suffix=$(get_libname)
	echo ${suffix//\.}
}
netpbm_ldshlib() {
	# ultra dirty Darwin hack, but hey... in the end this is all it needs...
	case ${CHOST} in
		*-darwin*) echo '$(LDFLAGS) -dynamiclib -install_name ${EPREFIX}/usr/lib/libnetpbm.10.dylib';;
		*)         echo '$(LDFLAGS) -shared -Wl,-soname,$(SONAME)';;
	esac
}
netpbm_config() {
	if use $1 ; then
		[[ $2 != "!" ]] && echo -l${2:-$1}
	else
		echo NONE
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/netpbm-10.31-build.patch
	epatch "${FILESDIR}"/netpbm-10.48.00-pnmtopng-zlib.patch #291987
	epatch "${FILESDIR}"/${P}-sigpower.patch #310179

	epatch "${FILESDIR}"/${PN}-10.46.00-darwin.patch
	epatch "${FILESDIR}"/${PN}-10.46.00-solaris.patch
	epatch "${FILESDIR}"/${PN}-10.48.00-solaris.patch
	epatch "${FILESDIR}"/${PN}-10.48.00-interix.patch
	epatch "${FILESDIR}"/${PN}-10.49.00-darwin-signals.patch
	epatch "${FILESDIR}"/netpbm-prefix.patch
	eprefixify converter/pbm/pbmtox10bm generator/ppmrainbow \
		editor/{ppmfade,pnmflip,pnmquant,ppmquant,ppmshadow}

	# avoid ugly depend.mk warnings
	touch $(find . -name Makefile | sed s:Makefile:depend.mk:g)

	cat config.mk.in - >> config.mk <<-EOF
	# Misc crap
	BUILD_FIASCO = N
	SYMLINK = ln -sf

	# Toolchain options
	CC = $(tc-getCC) -Wall
	LD = \$(CC)
	CC_FOR_BUILD = $(tc-getBUILD_CC)
	LD_FOR_BUILD = \$(CC_FOR_BUILD)
	AR = $(tc-getAR)
	RANLIB = $(tc-getRANLIB)

	STRIPFLAG =
	CFLAGS_SHLIB = -fPIC

	LDRELOC = \$(LD) -r
	LDSHLIB = $(netpbm_ldshlib)
	LINKER_CAN_DO_EXPLICIT_LIBRARY = N # we can, but dont want to
	LINKERISCOMPILER = Y
	NETPBMLIBSUFFIX = $(netpbm_libsuffix)
	NETPBMLIBTYPE = $(netpbm_libtype)

	# Gentoo build options
	TIFFLIB = $(netpbm_config tiff)
	JPEGLIB = $(netpbm_config jpeg)
	PNGLIB = $(netpbm_config png)
	ZLIB = $(netpbm_config zlib z)
	LINUXSVGALIB = $(netpbm_config svga vga)
	XML2_LIBS = $(netpbm_config xml xml2)
	JBIGLIB = -ljbig
	JBIGHDR_DIR = $(netpbm_config jbig "!")
	JASPERLIB = -ljasper
	JASPERHDR_DIR = $(netpbm_config jpeg2k "!")
	URTLIB = $(netpbm_config rle)
	URTHDR_DIR =
	X11LIB = $(netpbm_config X X11)
	X11HDR_DIR =
	EOF
	# cannot chain the die with the heredoc above as bash-3
	# has a parser bug in that setup #282902
	[ $? -eq 0 ] || die "writing config.mk failed"
}

src_compile() {
	# Solaris doesn't have vasprintf, libiberty does have it, for gethostbyname
	# we need -lnsl, for connect -lsocket
	[[ ${CHOST} == *-solaris* ]] && extlibs="-liberty -lnsl -lsocket"
	# same holds for interix, but we only need iberty
	[[ ${CHOST} == *-interix* ]] && extlibs="-liberty"

	emake LIBS="${extlibs}" -j1 || die
}

src_install() {
	mkdir -p "${ED}"
	emake -j1 package pkgdir="${ED}"/usr || die "make package failed"

	[[ $(get_libdir) != "lib" ]] && mv "${ED}"/usr/lib "${ED}"/usr/$(get_libdir)

	# Remove cruft that we don't need, and move around stuff we want
	rm -f "${ED}"/usr/bin/{doc.url,manweb} || die
	rm -r "${ED}"/usr/man/web || die
	rm -r "${ED}"/usr/link || die
	rm -f "${ED}"/usr/{README,VERSION,config_template,pkginfo} || die
	dodir /usr/share
	mv "${ED}"/usr/man "${ED}"/usr/share/ || die
	mv "${ED}"/usr/misc "${ED}"/usr/share/netpbm || die

	dodoc README
	cd doc
	GLOBIGNORE='*.html:.*' dodoc *
	dohtml -r .

	cd "${WORKDIR}"/${PN}-${MAN_VER}-manpages || die
	doman *.[0-9]
	dodoc README* gen-netpbm-manpages
}
