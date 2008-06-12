# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/fcgi/fcgi-2.4.0-r2.ebuild,v 1.9 2008/01/12 20:26:52 grobian Exp $

EAPI="prefix"

inherit eutils autotools multilib

DESCRIPTION="FastCGI Developer's Kit"
HOMEPAGE="http://www.fastcgi.com/"
SRC_URI="http://www.fastcgi.com/dist/${P}.tar.gz"

LICENSE="FastCGI"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="html"

DEPEND=""
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-Makefile.patch"
	epatch "${FILESDIR}/${P}-clientdata-pointer.patch"
	epatch "${FILESDIR}/${P}-html-updates.patch"

	eautoreconf
}

src_compile() {
	econf || die "econf failed"
	make || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install LIBRARY_PATH="${ED}/usr/$(get_libdir)" || die

	dodoc README

	# install the manpages into the right place
	doman doc/*.[13]

	# Only install the html documentation if USE=html
	if use html ; then
		dohtml "${S}"/doc/*/*
		insinto /usr/share/doc/${PF}/html
		doins -r "${S}/images"
	fi

	# install examples in the right place
	insinto /usr/share/doc/${PF}/examples
	doins "${S}/examples/"*.c
}
