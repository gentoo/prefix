# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils

DESCRIPTION="i6fork provides a fixed fork version for interix 6"
HOMEPAGE="http://dev.gentoo.org/~mduft/i6fork"
SRC_URI="${HOMEPAGE}/${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="-* ~x86-interix"

pkg_setup() {
	if [[ ${CHOST} != *-interix6* ]]; then
		die "only interix 6 is supported by i6fork. other versions don't require this!"
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-preload.patch
}

src_install() {
	emake DESTDIR="${D}" install

	echo "LD_PRELOAD='${EPREFIX}/usr/lib/libi6fork.so'" >> "${T}/00${PN}" || die
	doenvd "${T}/00${PN}" || die
}

