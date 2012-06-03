# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-ftp/lftp/lftp-4.3.7.ebuild,v 1.1 2012/05/30 13:41:48 jer Exp $

EAPI="4"

inherit eutils autotools libtool

DESCRIPTION="A sophisticated ftp/sftp/http/https/torrent client and file transfer program"
HOMEPAGE="http://lftp.yar.ru/"
SRC_URI="http://ftp.yars.free.net/pub/source/${PN}/${P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"

LFTP_LINGUAS="cs de es fr it ja ko pl pt_BR ru zh_CN zh_HK zh_TW"

IUSE="
	$( for i in ${LFTP_LINGUAS}; do echo linguas_${i}; done )
	gnutls nls socks5 +ssl
"

RDEPEND="
	dev-libs/expat
	>=sys-libs/ncurses-5.1
	socks5? (
		>=net-proxy/dante-1.1.12
		virtual/pam )
	ssl? (
		gnutls? ( >=net-libs/gnutls-1.2.3 )
		!gnutls? ( >=dev-libs/openssl-0.9.6 )
	)
	>=sys-libs/readline-5.1
"

DEPEND="
	${RDEPEND}
	=sys-devel/libtool-2*
	app-arch/xz-utils
	dev-lang/perl
	virtual/pkgconfig
	nls? ( sys-devel/gettext )
"

DOCS=(
	BUGS ChangeLog FAQ FEATURES MIRRORS NEWS README  README.debug-levels
	README.dnssec  README.modules THANKS TODO
)

src_prepare() {
	epatch \
		"${FILESDIR}/${PN}-4.0.2.91-lafile.patch" \
		"${FILESDIR}/${PN}-4.0.3-autoconf-2.64.patch" \
		"${FILESDIR}/${PN}-4.3.5-autopoint.patch"
	epatch "${FILESDIR}"/${PN}-3.7.14-darwin-bundle.patch
	eautoreconf
	elibtoolize # for Darwin bundles
}

src_configure() {
	local myconf=""

	if use ssl && use gnutls ; then
		myconf="${myconf} --without-openssl"
	elif use ssl && ! use gnutls ; then
		myconf="${myconf} --without-gnutls --with-openssl=${EPREFIX}/usr"
	else
		myconf="${myconf} --without-gnutls --without-openssl"
	fi

	use socks5 && myconf="${myconf} --with-socksdante=${EPREFIX}/usr" \
		|| myconf="${myconf} --without-socksdante"

	econf \
		--enable-packager-mode \
		--sysconfdir="${EPREFIX}"/etc/lftp \
		--with-modules \
		$(use_enable nls) \
		${myconf}
}
