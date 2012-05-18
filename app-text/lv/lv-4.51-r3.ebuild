# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/lv/lv-4.51-r3.ebuild,v 1.6 2012/03/06 21:43:00 ranger Exp $

EAPI="4"

inherit eutils toolchain-funcs

MY_P="${PN}${PV//./}"

DESCRIPTION="Powerful Multilingual File Viewer"
HOMEPAGE="http://www.ff.iij4u.or.jp/~nrt/lv/"
SRC_URI="http://www.ff.iij4u.or.jp/~nrt/freeware/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

RDEPEND="sys-libs/ncurses
	!app-editors/levee"
DEPEND="${RDEPEND}
	dev-lang/perl"
S="${WORKDIR}/${MY_P}"

src_prepare() {
	epatch "${FILESDIR}"/${P}-gentoo.patch
	epatch "${FILESDIR}"/${P}-xz.diff

	cd "${S}"/..
	epatch "${FILESDIR}"/${P}-interix.patch
}

src_configure() {
	[[ ${CHOST} == *-interix* ]] && export ac_cv_func_sigvec=no
	ECONF_SOURCE=src econf
}

src_compile() {
	emake CC="$(tc-getCC)"
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc README hello.sample
	dohtml index.html relnote.html hello.sample.gif
}
