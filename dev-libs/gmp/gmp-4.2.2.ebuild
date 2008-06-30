# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/gmp/gmp-4.2.2.ebuild,v 1.8 2007/12/31 05:51:07 vapier Exp $

EAPI="prefix"

inherit flag-o-matic eutils libtool

DESCRIPTION="Library for arithmetic on arbitrary precision integers, rational numbers, and floating-point numbers"
HOMEPAGE="http://gmplib.org/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2
	doc? ( http://gmplib.org/${PN}-man-${PV}.pdf )"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x86-solaris"
IUSE="doc nocxx"

RDEPEND=""
DEPEND=""

src_unpack () {
	unpack ${A}
	cd "${S}"
	[[ -d ${FILESDIR}/${PV} ]] && EPATCH_SUFFIX="diff" EPATCH_FORCE="yes" epatch "${FILESDIR}"/${PV}

	# This is linux (elf) only:
	# The assembler on interix fex does not understand #ifdef.
	[[ ${CHOST} == *-linux* ]] && epatch "${FILESDIR}"/${PN}-4.1.4-noexecstack.patch

	epatch "${FILESDIR}"/${PN}-4.2.2-ABI-multilib.patch
	epatch "${FILESDIR}"/${PN}-4.2.1-s390.diff

	sed -i -e 's:ABI = @ABI@:GMPABI = @GMPABI@:' \
		Makefile.in */Makefile.in */*/Makefile.in

	# note: we cannot run autotools here as gcc depends on this package
	elibtoolize
}

src_compile() {
	local myconf

	# GMP believes hppa2.0 is 64bit
	local is_hppa_2_0
	if [[ ${CHOST} == hppa2.0-* ]] ; then
		is_hppa_2_0=1
		export CHOST=${CHOST/2.0/1.1}
	fi

	# From fink (http://fink.cvs.sourceforge.net): due to assembler
	# differences on Darwin x86 with ELF based gnu assemblers we need
	# to "turn off" assembly on the Intel build for now.
	if [[ ${CHOST} == i?86-apple-darwin* ]] ; then
		myconf="${myconf} --host=none-apple-darwin"
	fi

	# ABI mappings (needs all architectures supported)
	case ${ABI} in
		32|x86)       export GMPABI=32;;
		64|amd64|n64) export GMPABI=64;;
		o32|n32)      export GMPABI=${ABI};;
	esac

	econf \
		--localstatedir="${EPREFIX}"/var/state/gmp \
		--disable-mpfr \
		--disable-mpbsd \
		$(use_enable !nocxx cxx) \
		${myconf} \
		|| die "configure failed"

	# Fix the ABI for hppa2.0
	if [[ -n ${is_hppa_2_0} ]] ; then
		sed -i \
			-e 's:pa32/hppa1_1:pa32/hppa2_0:' \
			"${S}"/config.h || die
		export CHOST=${CHOST/1.1/2.0}
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
