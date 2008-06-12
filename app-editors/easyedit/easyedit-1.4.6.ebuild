# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/easyedit/easyedit-1.4.6.ebuild,v 1.19 2008/01/26 15:48:14 grobian Exp $

EAPI="prefix"

IUSE=""

MY_P=ee-${PV}

DESCRIPTION="An easy to use text editor. Intended to be usable with little or no instruction."
HOMEPAGE="http://mahon.cwx.net/"
SRC_URI="http://mahon.cwx.net/sources/${MY_P}.src.tgz"

LICENSE="Artistic"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos"
SLOT="0"

DEPEND=">=sys-libs/ncurses-5.0"

src_compile() {

	emake -j1 || die

}

src_install() {

	dobin ee
	doman ee.1
	dodoc README.ee Changes ee.i18n.guide ee.msg

}
