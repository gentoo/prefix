# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/a52dec/a52dec-0.7.4-r6.ebuild,v 1.4 2009/06/02 23:55:32 beandog Exp $

WANT_AUTOCONF=latest
WANT_AUTOMAKE=latest

inherit eutils flag-o-matic libtool autotools

DESCRIPTION="library for decoding ATSC A/52 streams used in DVD"
HOMEPAGE="http://liba52.sourceforge.net/"
SRC_URI="http://liba52.sourceforge.net/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="oss djbfft"

RDEPEND="djbfft? ( sci-libs/djbfft )"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}

	cd "${S}"
	epatch "${FILESDIR}/${P}-build.patch"
	epatch "${FILESDIR}/${P}-freebsd.patch"
	epatch "${FILESDIR}/${P}-tests-optional.patch"

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

src_test() {
	filter-flags -fPIE
	emake check || die "emake check failed"
}

src_install() {
	make DESTDIR="${D}" docdir=/usr/share/doc/${PF}/html install || die

	insinto /usr/include/a52dec
	doins "${S}"/liba52/a52_internal.h

	dodoc AUTHORS ChangeLog HISTORY NEWS README TODO doc/liba52.txt
}
