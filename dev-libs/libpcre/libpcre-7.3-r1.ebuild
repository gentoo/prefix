# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libpcre/libpcre-7.3-r1.ebuild,v 1.10 2007/12/11 10:03:12 vapier Exp $

EAPI="prefix"

inherit libtool eutils

MY_P="pcre-${PV}"

DESCRIPTION="Perl-compatible regular expression library"
HOMEPAGE="http://www.pcre.org/"
SRC_URI="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${MY_P}.tar.bz2"

LICENSE="BSD"
SLOT="3"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"
IUSE="doc unicode"

DEPEND="dev-util/pkgconfig"
RDEPEND=""

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	elibtoolize
}

src_compile() {
	if use unicode; then
		myconf="--enable-utf8 --enable-unicode-properties"
	fi
	myconf="${myconf} --with-match-limit-recursion=8192"
	# Enable building of static libs too - grep and others
	# depend on them being built: bug 164099
	econf ${myconf} --enable-static || die "econf failed"
	emake all || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	dodoc doc/*.txt AUTHORS
	use doc && dohtml doc/html/*
}
