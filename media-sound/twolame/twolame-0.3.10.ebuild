# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/twolame/twolame-0.3.10.ebuild,v 1.6 2007/11/11 13:48:27 cla Exp $

EAPI="prefix"

DESCRIPTION="TwoLAME is an optimised MPEG Audio Layer 2 (MP2) encoder"
HOMEPAGE="http://www.twolame.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"
IUSE="doc"

DEPEND=">=media-libs/libsndfile-1.0.11"

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog README TODO

	# Fix documentation installation wrt #188830.
	rm -rf "${ED}"/usr/share/doc/${PN}
	if use doc; then
		dohtml doc/html/*
		dodoc doc/*.txt
	fi
}
