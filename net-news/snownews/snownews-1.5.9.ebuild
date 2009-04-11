# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-news/snownews/snownews-1.5.9.ebuild,v 1.2 2008/02/18 16:49:38 cedk Exp $

inherit eutils toolchain-funcs

DESCRIPTION="Snownews, a text-mode RSS/RDF newsreader"
HOMEPAGE="http://snownews.kcore.de/"
SRC_URI="http://home.kcore.de/~kiza/software/snownews/download/${P}.tar.gz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="unicode"

DEPEND=">=dev-libs/libxml2-2.5.6
	>=sys-libs/ncurses-5.3"

RDEPEND="dev-perl/XML-LibXML
	dev-perl/XML-LibXSLT
	dev-perl/libwww-perl"

pkg_setup() {
	if use unicode && ! built_with_use sys-libs/ncurses unicode; then
		eerror "sys-libs/ncurses must be build with unicode"
		die "${PN} requires sys-libs/ncurses with USE=unicode"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	sed -i -e "s/-O2//" \
		configure

	sed -i -e 's/$(INSTALL) -s/$(INSTALL)/' \
		Makefile

	#Bug #121805
	epatch "${FILESDIR}"/${PN}-1.5.7-stdint.patch
}

src_compile() {
	local conf="--prefix=${EPREFIX}/usr"
	use unicode && conf="${conf} --charset=UTF-8"
	./configure ${conf} || die "configure failed"
	emake CC="$(tc-getCC)" EXTRA_CFLAGS="${CFLAGS}" EXTRA_LDFLAGS="${LDFLAGS}" || die "emake failed"
}

src_install() {
	emake PREFIX="${ED}/usr" install || die "make install failed"

	dodoc AUTHOR CREDITS README README.colors README.de README.patching
}
