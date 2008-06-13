# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libesmtp/libesmtp-1.0.4.ebuild,v 1.12 2008/02/12 12:14:58 flameeyes Exp $

EAPI="prefix"

inherit toolchain-funcs eutils libtool

DESCRIPTION="libESMTP is a library that implements the client side of the SMTP protocol"
SRC_URI="http://www.stafford.uklinux.net/${PN}/${P}.tar.bz2"
HOMEPAGE="http://www.stafford.uklinux.net/libesmtp/"
LICENSE="LGPL-2.1 GPL-2"

RDEPEND="ssl? ( >=dev-libs/openssl-0.9.6b )"
DEPEND=">=sys-devel/libtool-1.4.1
		>=sys-apps/sed-4
		${RDEPEND}"

IUSE="ssl debug"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

src_unpack() {
	unpack ${A}

	elibtoolize
}

src_compile() {
	local myconf

	if [[ $(gcc-major-version) == 2 ]]; then
		myconf="${myconf} --disable-isoc"
	fi

	econf \
		--enable-all \
		--enable-threads \
		$(use_with ssl) \
		$(use_enable debug) \
		${myconf} || die "configure failed"

	if [[ $(gcc-major-version) == 3 ]] && [[ $(gcc-minor-version) == 3 ]]; then
		sed -i "s:-Wsign-promo::g" Makefile
	fi

	emake || die "emake failed"
}

src_install () {

	make DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS INSTALL ChangeLog NEWS Notes README TODO
	dohtml doc/api.xml

}
