# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/openjpeg/openjpeg-1.3-r2.ebuild,v 1.7 2009/05/21 19:02:01 ranger Exp $

inherit eutils toolchain-funcs multilib flag-o-matic

DESCRIPTION="An open-source JPEG 2000 codec written in C"
HOMEPAGE="http://www.openjpeg.org/"
SRC_URI="http://www.openjpeg.org/openjpeg_v${PV//./_}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="tools"
DEPEND="tools? ( >=media-libs/tiff-3.8.2 )"
RDEPEND=${DEPEND}

S="${WORKDIR}/OpenJPEG_v1_3"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-Makefile.patch #258373
	cp "${FILESDIR}"/${P}-codec-Makefile "${S}"/codec/Makefile
	epatch "${FILESDIR}"/${P}-freebsd.patch #253012
	epatch "${FILESDIR}"/${P}-darwin.patch # needs to go after freebsd patch
}

src_compile() {
	# AltiVec on OSX/PPC screws up the build :(
	[[ ${CHOST} == powerpc*-apple-darwin* ]] && filter-flags -m*

	emake CC="$(tc-getCC)" AR="$(tc-getAR)" LIBRARIES="-lm" PREFIX="${EPREFIX}/usr" TARGOS=$(uname) COMPILERFLAGS="${CFLAGS} -std=c99 -fPIC" || die "emake failed"
	if use tools; then
		emake -C codec CC="$(tc-getCC)" || die "emake failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" TARGOS=$(uname) INSTALL_LIBDIR="${EPREFIX}/usr/$(get_libdir)" install || die "install failed"
	if use tools; then
		emake -C codec DESTDIR="${D}" PREFIX="${EPREFIX}/usr" INSTALL_BINDIR="${EPREFIX}/usr/bin" install || die "install failed"
	fi
	dodoc ChangeLog
}
