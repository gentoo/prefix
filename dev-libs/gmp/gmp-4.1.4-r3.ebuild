# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/gmp/gmp-4.1.4-r3.ebuild,v 1.1 2006/01/29 10:21:09 vapier Exp $

EAPI="prefix"

inherit flag-o-matic eutils libtool

DESCRIPTION="Library for arithmetic on arbitrary precision integers, rational numbers, and floating-point numbers"
HOMEPAGE="http://www.swox.com/gmp/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2
	doc? ( http://www.swox.se/${PN}/${PN}-man-${PV}.pdf )"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="doc nocxx"

RDEPEND=""
DEPEND=""

src_unpack () {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PV}/*.diff
	epatch "${FILESDIR}"/${P}-noexecstack.patch
	use ppc64 && epatch "${FILESDIR}"/${P}-asm-dots.patch
	epatch "${FILESDIR}"/${P}-ABI-multilib.patch
	epatch "${FILESDIR}"/${PN}-hppa-2.0.patch

	# note: we cannot run autotools here as gcc depends on this package
	elibtoolize
}

src_compile() {
	filter-flags -ffast-math

	# We need to force 1.0 ABI as 2.0w requires 64bit userland
	use hppa && export GMPABI="1.0"

	# FreeBSD libc already have bsdmp
	econf \
		$(with_localstatedir /var/state/gmp) \
		--disable-mpfr \
		$(use_enable !nocxx cxx) \
		$(use_enable !elibc_FreeBSD mpbsd) \
		|| die "configure failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${EDEST}" install || die "make install failed"

	dodoc AUTHORS ChangeLog NEWS README
	dodoc doc/configuration doc/isa_abi_headache
	dohtml -r doc

	use doc && cp "${DISTDIR}"/gmp-man-${PV}.pdf "${D}"/usr/share/doc/${PF}/
}
