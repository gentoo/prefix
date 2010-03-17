# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/vilistextum/vilistextum-2.6.9.ebuild,v 1.2 2010/03/06 21:55:52 jlec Exp $

EAPI="2"

inherit eutils autotools flag-o-matic

DESCRIPTION="Html to ascii converter specifically programmed to get the best out of incorrect html."
HOMEPAGE="http://bhaak.dyndns.org/vilistextum/"
SRC_URI="http://bhaak.dyndns.org/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris"
#IUSE="unicode kde"
IUSE="unicode"

DEPEND=""
# KDE support will be available once a version of kaptain in stable
#	 kde? ( kde-misc/kaptain )"

src_prepare() {
	epatch "${FILESDIR}/${P}-gentoo.diff"
	eautoreconf
}

src_configure(){
	use elibc_glibc || append-libs -liconv
	# need hardwired locale simply because locale -a | grep -i utf-8 | head -n1
	# isn't always returning the most sensical (and working) locale
	econf $(use_enable unicode multibyte) \
		$(use_with unicode unicode-locale en_US.UTF-8)
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc README CHANGES || die
	dohtml doc/*.html || die
}
