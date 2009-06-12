# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/catdoc/catdoc-0.94.2-r1.ebuild,v 1.2 2009/06/09 12:39:47 flameeyes Exp $

WANT_AUTOMAKE=none

inherit autotools eutils

DESCRIPTION="A convertor for Microsoft Word, Excel and RTF Files to text"
HOMEPAGE="http://www.wagner.pp.ru/~vitus/software/catdoc/"
SRC_URI="http://ftp.wagner.pp.ru/pub/${PN}/${P}.tar.gz"
LICENSE="GPL-2"

IUSE="tk"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris"

DEPEND="tk? ( >=dev-lang/tk-8.1 )"

DOCS="CODING.STD CREDITS NEWS README TODO"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-flags.patch"
	epatch "${FILESDIR}/${P}+autoconf-2.63.patch"
	eautoconf
}

src_compile() {

	local myconf="--with-install-root=${D}"

	use tk \
		&& myconf="${myconf} --with-wish=${EPREFIX}/usr/bin/wish" \
		|| myconf="${myconf} --disable-wordview"

	econf ${myconf} || die
	emake LIB_DIR=/usr/share/catdoc || die

}

src_install() {

	rm -f install # stupid system, this file prevents a make install
	emake -j1 mandir="${EPREFIX}"/usr/share/man/man1 install || die
	dodoc ${DOCS}

}
