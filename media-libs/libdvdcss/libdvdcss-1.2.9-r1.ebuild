# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/media-libs/libdvdcss/libdvdcss-1.2.9-r1.ebuild,v 1.1 2007/02/05 11:25:05 flameeyes Exp $

EAPI="prefix"

inherit eutils autotools

DESCRIPTION="A portable abstraction library for DVD decryption"
HOMEPAGE="http://developers.videolan.org/libdvdcss/"
SRC_URI="http://www.videolan.org/pub/${PN}/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="1.2"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE="doc"

DEPEND="doc? ( app-doc/doxygen )"
RDEPEND=""

pkg_preinst() {
	# these could cause problems if they exist from
	# earlier builds
	for x in libdvdcss.so.0 libdvdcss.so.1 libdvdcss.0.dylib libdvdcss.1.dylib ; do
		if [[ -e ${EROOT}/usr/$(get_libdir)/${x} ]] ; then
			rm -f "${EROOT}"/usr/$(get_libdir)/${x}
		fi
	done
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# add configure switches to enable/disable doc building
	epatch "${FILESDIR}"/${P}-doc.patch

	eautoreconf
}

src_compile() {
	# See bug #98854, requires access to fonts cache for TeX
	use doc && addwrite /var/cache/fonts

	econf \
		--enable-static --enable-shared \
		$(use_enable doc) \
		--disable-dependency-tracking || die
	emake || die
}

src_install() {
	make install DESTDIR="${D}" || die

	dodoc AUTHORS ChangeLog NEWS README
	use doc && dohtml doc/html/*
}
