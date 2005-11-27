# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libpcre/libpcre-6.3.ebuild,v 1.9 2005/08/24 00:01:18 vapier Exp $

EAPI="prefix"

inherit libtool flag-o-matic eutils

DESCRIPTION="Perl-compatible regular expression library"
HOMEPAGE="http://www.pcre.org/"
SRC_URI="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PV}.tar.bz2"

LICENSE="BSD"
SLOT="3"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc-macos ppc64 s390 sh sparc x86"
IUSE="doc"

DEPEND="dev-util/pkgconfig"

S=${WORKDIR}/pcre-${PV}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/pcre-6.3-uclibc-tuple.patch

	# TODO: Fix this.  Use -fPIC just for the shared objects.
	# position-independent code must used for all shared objects.
	ewarn "TODO: Fix this bad -fPIC handling"
	append-flags -fPIC
}

src_compile() {
	# How about the following flags?
	# --enable-unicode-properties  enable Unicode properties support
	# --disable-stack-for-recursion  disable use of stack recursion when matching
	econf --enable-utf8 || die
	emake all libpcrecpp.la || die
}

src_install() {
	make DESTDIR="${DEST}" install || die

	dodoc AUTHORS INSTALL NON-UNIX-USE
	dodoc doc/*.txt doc/Tech.Notes
	use doc && dohtml doc/html/*
}
