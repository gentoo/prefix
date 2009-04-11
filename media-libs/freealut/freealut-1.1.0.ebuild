# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/freealut/freealut-1.1.0.ebuild,v 1.13 2009/03/11 20:29:46 tupone Exp $

inherit autotools eutils

DESCRIPTION="The OpenAL Utility Toolkit"
SRC_URI="http://www.openal.org/openal_webstf/downloads/${P}.tar.gz"
HOMEPAGE="http://www.openal.org"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="media-libs/openal"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Link against openal and pthread
	sed -i -e 's/libalut_la_LIBADD = .*/& -lopenal -lpthread/' src/Makefile.am
	AT_M4DIR="${S}/admin/autotools/m4" eautoreconf
}

src_compile() {
	econf \
		--libdir="${EPREFIX}/usr/$(get_libdir)" || die
	emake all || die
}

src_install() {
	make install DESTDIR="${D}" || die

	dodoc AUTHORS ChangeLog NEWS README
	dohtml doc/*
}
