# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/lv/lv-4.51-r1.ebuild,v 1.6 2008/12/01 21:45:21 ranger Exp $

inherit eutils

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

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-gentoo.patch

	cd "${S}"/..
	epatch "${FILESDIR}"/${P}-interix.patch
}

src_compile() {
	[[ ${CHOST} == *-interix* ]] && export ac_cv_func_sigvec=no

	ECONF_SOURCE=src econf || die
	emake CC="$(tc-getCC)" || die
}

src_install() {
	emake DESTDIR="${D}" install || die

	dodoc README hello.sample
	dohtml index.html relnote.html hello.sample.gif
}
