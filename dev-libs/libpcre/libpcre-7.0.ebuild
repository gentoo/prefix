# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libpcre/libpcre-7.0.ebuild,v 1.2 2007/01/27 20:03:36 masterdriverz Exp $

EAPI="prefix"

inherit libtool eutils

MY_P="pcre-${PV}"

DESCRIPTION="Perl-compatible regular expression library"
HOMEPAGE="http://www.pcre.org/"
SRC_URI="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${MY_P}.tar.bz2"

LICENSE="BSD"
SLOT="3"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="doc unicode"

DEPEND="dev-util/pkgconfig"
RDEPEND=""

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/pcre-6.3-uclibc-tuple.patch"
	epatch "${FILESDIR}/pcre-6.4-link.patch"

	# Added for bug #130668 -- fix parallel builds
	epatch "${FILESDIR}/pcre-6.6-parallel-build.patch"

	elibtoolize
}

src_compile() {
	if use unicode; then
		myconf="--enable-utf8 --enable-unicode-properties"
	fi

	# Enable building of static libs too - grep and others
	# depend on them being built: bug 164099
	econf ${myconf} --enable-static || die "econf failed"
	emake all libpcrecpp.la || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"

	dodoc doc/*.txt doc/Tech.Notes AUTHORS
	use doc && dohtml doc/html/*
}
