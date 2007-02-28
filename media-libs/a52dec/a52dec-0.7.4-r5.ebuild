# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/a52dec/a52dec-0.7.4-r5.ebuild,v 1.16 2006/09/27 08:38:17 flameeyes Exp $

EAPI="prefix"

WANT_AUTOCONF=latest
WANT_AUTOMAKE=latest

inherit eutils flag-o-matic libtool autotools

DESCRIPTION="library for decoding ATSC A/52 streams used in DVD"
HOMEPAGE="http://liba52.sourceforge.net/"
SRC_URI="http://liba52.sourceforge.net/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE="oss djbfft"

DEPEND="djbfft? ( sci-libs/djbfft )"
RDEPEND=""

src_unpack() {
	unpack ${A}

	cd "${S}"
	epatch "${FILESDIR}/${P}-build.patch"
	epatch "${FILESDIR}/${P}-freebsd.patch"

	eautoreconf
	epunt_cxx
}

src_compile() {
	filter-flags -fprefetch-loop-arrays

	local myconf="--enable-shared"
	use oss || myconf="${myconf} --disable-oss"
	econf \
		$(use_enable djbfft) \
		${myconf} || die
	emake CFLAGS="${CFLAGS}" || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" docdir=/usr/share/doc/${PF}/html install || die

	insinto /usr/include/a52dec
	doins ${S}/liba52/a52_internal.h

	dodoc AUTHORS ChangeLog HISTORY NEWS README TODO doc/liba52.txt
}
