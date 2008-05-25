# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/netpbm/netpbm-10.41.0.ebuild,v 1.3 2008/02/16 20:56:18 vapier Exp $

EAPI="prefix"

inherit flag-o-matic toolchain-funcs eutils multilib

MAN_VER=10.33
DESCRIPTION="A set of utilities for converting to/from the netpbm (and related) formats"
HOMEPAGE="http://netpbm.sourceforge.net/"
SRC_URI="mirror://gentoo/${P}.tar.lzma
	mirror://gentoo/${PN}-${MAN_VER}-manpages.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="jbig jpeg jpeg2k png rle svga tiff xml zlib"

RDEPEND="jpeg? ( >=media-libs/jpeg-6b )
	jpeg2k? ( media-libs/jasper )
	tiff? ( >=media-libs/tiff-3.5.5 )
	png? ( >=media-libs/libpng-1.2.1 )
	xml? ( dev-libs/libxml2 )
	zlib? ( sys-libs/zlib )
	svga? ( media-libs/svgalib )
	jbig? ( media-libs/jbigkit )
	rle? ( media-libs/urt )"
DEPEND="${RDEPEND}
	app-arch/lzma-utils"

maint_pkg_create() {
	local base="/usr/local/src"
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
#pkg_setup() { [[ -e ${DISTDIR}/${P}.tar.lzma ]] || maint_pkg_create ; }

netpbm_libtype() {
	case ${CHOST} in
		*-darwin*) echo dylib;;
		*)		   echo unixshared;;
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
		*)		   echo '$(LDFLAGS) -shared -Wl,-soname,$(SONAME)';;
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
	epatch "${FILESDIR}"/netpbm-10.35.0-xml2.patch #137871

	epatch "${FILESDIR}"/netpbm-prefix.patch
	epatch "${FILESDIR}"/${P}-interix.patch
	eprefixify converter/pbm/pbmtox10bm generator/ppmrainbow \
	editor/{ppmfade,pnmflip,pnmquant,ppmquant,ppmshadow}

	rm -f configure
	cp Makefile.config.in Makefile.config
	cat >> Makefile.config <<-EOF
	# Gentoo toolchain options
	CC = $(tc-getCC) -Wall
	CC_FOR_BUILD = $(tc-getBUILD_CC)
	AR = $(tc-getAR)
	RANLIB = $(tc-getRANLIB)
	STRIPFLAG =
	CFLAGS_SHLIB = -fPIC

	# workaround parallel build issues
	SYMLINK = ln -sf

	NETPBMLIBTYPE = $(netpbm_libtype)
	NETPBMLIBSUFFIX = $(netpbm_libsuffix)
	LDSHLIB = $(netpbm_ldshlib)

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
	EOF

	[[ ${CHOST} == *-interix3* ]] && echo "INTTYPES_H = <stdint.h>" >> Makefile.config
}

src_compile() {
	replace-flags -mcpu=ultrasparc "-mcpu=v8 -mtune=ultrasparc"
	replace-flags -mcpu=v9 "-mcpu=v8 -mtune=v9"
	[[ ${CHOST} == *-darwin* ]] && append-flags -fno-common
	# Solaris doesn't have vasprintf, libiberty does have it, for gethostbyname
	# we need -lnsl, for connect -lsocket
	[[ ${CHOST} == *-solaris* ]] && extlibs="-liberty -lnsl -lsocket"

	emake LIBS="-lz ${extlibs}" -j1 || die
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
