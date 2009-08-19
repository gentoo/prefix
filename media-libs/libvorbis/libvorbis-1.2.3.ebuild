# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libvorbis/libvorbis-1.2.3.ebuild,v 1.9 2009/08/18 17:27:43 ssuominen Exp $

EAPI=2
MY_P=${P/_}
inherit autotools flag-o-matic eutils toolchain-funcs

DESCRIPTION="The Ogg Vorbis sound file format library"
HOMEPAGE="http://xiph.org/vorbis"
SRC_URI="http://downloads.xiph.org/releases/vorbis/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc"

RDEPEND="media-libs/libogg"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S=${WORKDIR}/${MY_P}

src_prepare() {
	epatch "${FILESDIR}"/${P}-optional_examples_and_tests.patch

	sed -e 's:-O20::g' -e 's:-mfused-madd::g' -e 's:-mcpu=750::g' -e 's:-mv8::g' \
		-i configure.ac || die "sed failed"
	
	AT_M4DIR=m4 eautoreconf
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	rm -rf "${ED}"/usr/share/doc/${PN}*

	dodoc AUTHORS CHANGES README todo.txt

	if use doc; then
		docinto txt
		dodoc doc/*.txt
		docinto html
		dohtml -r doc/*
		insinto /usr/share/doc/${PF}/pdf
		doins doc/*.pdf
	fi
}
