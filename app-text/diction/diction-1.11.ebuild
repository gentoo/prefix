# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/diction/diction-1.11.ebuild,v 1.4 2008/01/19 22:08:48 grobian Exp $

EAPI="prefix"

DESCRIPTION="Diction and style checkers for english and german texts"
HOMEPAGE="http://www.gnu.org/software/diction/diction.html"
SRC_URI="http://www.moria.de/~michael/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="unicode"

DEPEND="sys-devel/gettext
	virtual/libintl"

src_unpack() {
	unpack ${A}
	cd "${S}"
	if use unicode; then
		for lang in de nl; do
			iconv -f ISO-8859-1 -t UTF-8 ${lang} > ${lang}.new || die "iconv failed."
			mv ${lang}.new ${lang}
		done
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc NEWS README
}
