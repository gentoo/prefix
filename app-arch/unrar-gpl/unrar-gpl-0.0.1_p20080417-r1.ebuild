# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/unrar-gpl/unrar-gpl-0.0.1_p20080417-r1.ebuild,v 1.1 2010/06/30 21:31:57 hanno Exp $

EAPI=2
inherit autotools flag-o-matic

DESCRIPTION="Free rar unpacker for old (pre v3) rar files"
HOMEPAGE="http://home.gna.org/unrar/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""
DEPEND="!elibc_glibc? ( dev-libs/argp dev-libs/gnulib )"
S="${WORKDIR}/${PN/-gpl}"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-0.0.1-solaris.patch
	eautoreconf || die "eautoreconf failed"
}

src_configure() {
	if [[ ${CHOST} == *-aix* || ${CHOST} == *-solaris* ]]; then
		append-flags -I"${EPREFIX}"/usr/$(get_libdir)/gnulib/include
		append-ldflags -L"${EPREFIX}"/usr/$(get_libdir)/gnulib/lib
		append-libs -lgnu
	fi
	econf --program-suffix="-gpl" || die "econf failed"
}

src_install() {
	make DESTDIR="${D}" install || die "install failed"
	dodoc AUTHORS README || die "dodoc failed"
}
