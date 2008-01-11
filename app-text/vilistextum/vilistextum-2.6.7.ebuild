# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/vilistextum/vilistextum-2.6.7.ebuild,v 1.9 2007/01/04 13:13:38 flameeyes Exp $

EAPI="prefix"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

inherit eutils autotools flag-o-matic

DESCRIPTION="Vilistextum is a html to ascii converter specifically programmed to get the best out of incorrect html."
HOMEPAGE="http://bhaak.dyndns.org/vilistextum/"
SRC_URI="http://bhaak.dyndns.org/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
#IUSE="unicode kde"
IUSE="unicode"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"

DEPEND=""
# KDE support will be available once a version of kaptain in stable
#	 kde? ( kde-misc/kaptain )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-gentoo.diff"
	epatch "${FILESDIR}/${P}-use-glibc-iconv.diff"

	eautoreconf
}

src_compile() {
	use elibc_glibc || append-ldflags -liconv
	econf \
		$(use_enable unicode multibyte) \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
	dodoc README CHANGES
	dohtml doc/*.{html,css}
}
