# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/openjpeg/openjpeg-1.3-r3.ebuild,v 1.1 2010/03/20 18:11:50 vapier Exp $

inherit eutils toolchain-funcs multilib flag-o-matic

MY_PV=${PV//./_}
DESCRIPTION="An open-source JPEG 2000 codec written in C"
HOMEPAGE="http://www.openjpeg.org/"
SRC_URI="http://www.openjpeg.org/openjpeg_v${MY_PV}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="tools"

DEPEND="tools? ( >=media-libs/tiff-3.8.2 )"
RDEPEND=${DEPEND}

S=${WORKDIR}/OpenJPEG_v${MY_PV}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-Makefile.patch #258373
	cp "${FILESDIR}"/${PF}-codec-Makefile "${S}"/codec/Makefile
	epatch "${FILESDIR}"/${P}-freebsd.patch #253012
	epatch "${FILESDIR}"/${P}-darwin.patch # needs to go after freebsd patch
	sed -i 's:defined(HAVE_STDBOOL_H):1:' libopenjpeg/openjpeg.h || die #305333
}

src_compile() {
	# AltiVec on OSX/PPC screws up the build :(
	[[ ${CHOST} == powerpc*-apple-darwin* ]] && filter-flags -m*

	tc-export CC AR
	# XXX: the -fPIC is wrong because it builds the libopenjpeg.a
	# as a PIC library too.  Should build up two sets of objects.
	emake CC="$CC" AR="$AR" LIBRARIES="-lm" PREFIX="${EPREFIX}/usr" TARGOS=$(uname) COMPILERFLAGS="${CFLAGS} ${CPPFLAGS} -fPIC" || die "emake failed"
	if use tools ; then
		ln -s libopenjpeg*$(get_libname)* libopenjpeg$(get_libname) || die
		emake -C codec || die "emake failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" TARGOS=$(uname) INSTALL_LIBDIR="${EPREFIX}/usr/$(get_libdir)" install || die "install failed"
	if use tools ; then
		emake -C codec DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install || die "install failed"
	fi
	dodoc ChangeLog
}
