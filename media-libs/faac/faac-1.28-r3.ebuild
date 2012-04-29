# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/faac/faac-1.28-r3.ebuild,v 1.1 2012/02/23 13:42:29 ssuominen Exp $

EAPI=4
inherit autotools eutils

DESCRIPTION="Free MPEG-4 audio codecs by AudioCoding.com"
HOMEPAGE="http://www.audiocoding.com"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1 MPEG-4"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="static-libs"

RDEPEND="media-libs/libmp4v2"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch \
		"${FILESDIR}"/${P}-external-libmp4v2.patch \
		"${FILESDIR}"/${P}-altivec.patch \
		"${FILESDIR}"/${P}-libmp4v2_r479_compat.patch
	epatch "${FILESDIR}"/${P}-solaris.patch

	eautoreconf
	epunt_cxx
}

src_configure() {
	econf $(use_enable static-libs static)
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc AUTHORS ChangeLog NEWS README TODO
	dohtml docs/*.html
	insinto /usr/share/doc/${PF}/pdf
	doins docs/libfaac.pdf
	find "${D}" -name '*.la' -exec rm -f {} +
}
