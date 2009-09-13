# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-i18n/enca/enca-1.10.ebuild,v 1.2 2009/09/12 17:02:57 arfrever Exp $

EAPI="2"

inherit toolchain-funcs

DESCRIPTION="ENCA detects the character coding of a file and converts it if desired"
HOMEPAGE="http://gitorious.org/enca"
SRC_URI="http://dl.cihar.com/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x86-solaris"
IUSE="doc"

DEPEND=">=app-text/recode-3.6_p15"
RDEPEND="${DEPEND}"

src_configure() {
	econf \
		--with-librecode="${EPREFIX}"/usr \
		--enable-external \
		$(use_enable doc gtk-doc)
}

src_compile() {
	if tc-is-cross-compiler; then
		pushd tools > /dev/null
		$(tc-getBUILD_CC) -o make_hash make_hash.c || die "native make_hash failed"
		popd > /dev/null
	fi
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
