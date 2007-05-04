# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/gmp/gmp-4.2.1-r1.ebuild,v 1.1 2007/04/04 21:58:11 vapier Exp $

EAPI="prefix"

inherit flag-o-matic eutils libtool

DESCRIPTION="Library for arithmetic on arbitrary precision integers, rational numbers, and floating-point numbers"
HOMEPAGE="http://www.swox.com/gmp/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2
	doc? ( http://www.swox.se/${PN}/${PN}-man-${PV}.pdf )"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE="doc nocxx"

RDEPEND=""
DEPEND=""

src_unpack () {
	unpack ${A}
	cd "${S}"
	EPATCH_SUFFIX="diff" EPATCH_FORCE="yes" epatch "${FILESDIR}"/${PV}
	epatch "${FILESDIR}"/${PN}-4.1.4-noexecstack.patch
	epatch "${FILESDIR}"/${P}-ABI-multilib.patch
	epatch "${FILESDIR}"/${P}-s390.diff

	sed -i -e 's:ABI = @ABI@:GMPABI = @GMPABI@:' \
		Makefile.in */Makefile.in */*/Makefile.in

	# note: we cannot run autotools here as gcc depends on this package
	elibtoolize
}

src_compile() {
	local myconf

	# GMP believes hppa2.0 is 64bit
	if [[ ${CHOST} == hppa2.0-* ]] ; then
		is_hppa_2_0=1
		export CHOST="${CHOST/2.0/1.1}"
	fi

	# From fink (http://fink.cvs.sourceforge.net): due to assembler
	# differences on Darwin x86 with ELF based gnu assemblers we need
	# to "turn off" assembly on the Intel build for now.
	if [[ ${CHOST} == i?86-apple-darwin* ]] ; then
		myconf="${myconf} --host=none-apple-darwin"
	fi

	# ABI mappings (needs all architectures supported)
	if [ -n "${ABI}" ]; then
		[ "${ABI}" = "32" ] && export GMPABI=32
		[ "${ABI}" = "64" ] && export GMPABI=64
		[ "${ABI}" = "x86" ] && export GMPABI=32
		[ "${ABI}" = "amd64" ] && export GMPABI=64
		[ "${ABI}" = "n64" ] && export GMPABI=64
		[ "${ABI}" = "o32" ] && export GMPABI=o32
		[ "${ABI}" = "n32" ] && export GMPABI=n32
	fi

	econf \
		$(with_localstatedir /var/state/gmp) \
		--disable-mpfr \
		--disable-mpbsd \
		$(use_enable !nocxx cxx) \
		${myconf} \
		|| die "configure failed"

	# Fix the ABI for hppa2.0
	if [ ! -z "${is_hppa_2_0}" ]; then
		sed -i "${S}/config.h" -e 's:pa32/hppa1_1:pa32/hppa2_0:'
		export CHOST="${CHOST/1.1/2.0}"
	fi

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	dodoc AUTHORS ChangeLog NEWS README
	dodoc doc/configuration doc/isa_abi_headache
	dohtml -r doc

	use doc && cp "${DISTDIR}"/gmp-man-${PV}.pdf "${ED}"/usr/share/doc/${PF}/
}
