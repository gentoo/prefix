# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/catdoc/catdoc-0.94.1.ebuild,v 1.2 2006/08/04 14:46:34 cardoe Exp $

EAPI="prefix"

DESCRIPTION="A convertor for Microsoft Word, Excel and RTF Files to text"
HOMEPAGE="http://www.45.free.net/~vitus/software/catdoc/"
SRC_URI="ftp://ftp.45.free.net/pub/${PN}/${P}.tar.gz"
LICENSE="GPL-2"

IUSE="tk"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"

DEPEND="tk? ( >=dev-lang/tk-8.1 )"

DOCS="CODING.STD CREDITS NEWS README TODO"

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
	make mandir="${EPREFIX}"/usr/share/man/man1 install || die
	dodoc ${DOCS}

}


