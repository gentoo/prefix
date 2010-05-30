# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/tk/tk-8.5.8.ebuild,v 1.1 2010/01/07 14:20:28 patrick Exp $

WANT_AUTOCONF=latest
WANT_AUTOMAKE=latest

inherit autotools eutils multilib toolchain-funcs prefix

MY_P="${PN}${PV/_beta/b}"
DESCRIPTION="Tk Widget Set"
HOMEPAGE="http://www.tcl.tk/"
SRC_URI="mirror://sourceforge/tcl/${MY_P}-src.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="debug threads truetype aqua"

RDEPEND="!aqua? ( x11-libs/libX11 )
	~dev-lang/tcl-${PV}"
DEPEND="${RDEPEND}
	!aqua? (
	truetype? ( x11-libs/libXft )
	x11-libs/libXt
	x11-proto/xproto
	)"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	if use threads ; then
		ewarn ""
		ewarn "PLEASE NOTE: You are compiling ${P} with"
		ewarn "threading enabled."
		ewarn "Threading is not supported by all applications"
		ewarn "that compile against tcl. You use threading at"
		ewarn "your own discretion."
		ewarn ""
		epause 5
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-8.4.11-multilib.patch

	epatch "${FILESDIR}"/${PN}-8.4.15-aqua.patch
	eprefixify unix/Makefile.in

	# Bug 125971
	epatch "${FILESDIR}"/${PN}-8.5_alpha6-tclm4-soname.patch

	cd "${S}"/unix
	eautoreconf
}

src_compile() {
	tc-export CC
	cd "${S}"/unix

	local mylibdir=$(get_libdir) ; mylibdir=${mylibdir//\/}

	econf \
		--with-tcl="${EPREFIX}"/usr/${mylibdir} \
		$(use_enable threads) \
		$(use_enable aqua) \
		$(use_enable truetype xft) \
		$(use_enable debug symbols) || die

	emake || die
}

src_install() {
	#short version number
	local v1
	v1=${PV%.*}

	cd "${S}"/unix
	S= emake DESTDIR="${D}" install || die

	# normalize $S path, bug #280766 (pkgcore)
	local nS="$(cd "${S}"; pwd)"

	# fix the tkConfig.sh to eliminate refs to the build directory
	local mylibdir=$(get_libdir) ; mylibdir=${mylibdir//\/}
	sed -i \
		-e "s,^\(TK_BUILD_LIB_SPEC='-L\)${nS}/unix,\1${EPREFIX}/usr/${mylibdir}," \
		-e "s,^\(TK_SRC_DIR='\)${nS}',\1${EPREFIX}/usr/${mylibdir}/tk${v1}/include'," \
		-e "s,^\(TK_BUILD_STUB_LIB_SPEC='-L\)${nS}/unix,\1${EPREFIX}/usr/${mylibdir}," \
		-e "s,^\(TK_BUILD_STUB_LIB_PATH='\)${nS}/unix,\1${EPREFIX}/usr/${mylibdir}," \
		"${ED}"/usr/${mylibdir}/tkConfig.sh || die
	[[ ${CHOST} != *-darwin* ]] && sed -i \
		-e "s,^\(TK_CC_SEARCH_FLAGS='.*\)',\1:${EPREFIX}/usr/${mylibdir}'," \
		-e "s,^\(TK_LD_SEARCH_FLAGS='.*\)',\1:${EPREFIX}/usr/${mylibdir}'," \
		"${ED}"/usr/${mylibdir}/tkConfig.sh

	# install private headers
	insinto /usr/${mylibdir}/tk${v1}/include/unix
	doins "${S}"/unix/*.h || die
	insinto /usr/${mylibdir}/tk${v1}/include/generic
	doins "${S}"/generic/*.h || die
	rm -f "${ED}"/usr/${mylibdir}/tk${v1}/include/generic/tk.h
	rm -f "${ED}"/usr/${mylibdir}/tk${v1}/include/generic/tkDecls.h
	rm -f "${ED}"/usr/${mylibdir}/tk${v1}/include/generic/tkPlatDecls.h

	# install symlink for libraries
	#dosym libtk${v1}.a /usr/${mylibdir}/libtk.a
	dosym libtk${v1}$(get_libname) /usr/${mylibdir}/libtk$(get_libname)
	dosym libtkstub${v1}.a /usr/${mylibdir}/libtkstub.a

	dosym wish${v1} /usr/bin/wish

	cd "${S}"
	dodoc ChangeLog* README changes
}
