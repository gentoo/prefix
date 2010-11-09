# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/aria2/aria2-1.10.0.ebuild,v 1.1 2010/07/19 09:21:48 dev-zero Exp $

EAPI="2"

inherit multilib

DESCRIPTION="A download utility with resuming and segmented downloading with HTTP/HTTPS/FTP/BitTorrent support."
HOMEPAGE="http://aria2.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"
LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
SLOT="0"
IUSE="ares bittorrent expat gnutls metalink nls scripts sqlite ssl test xmlrpc"

CDEPEND="sys-libs/zlib
	ssl? (
		gnutls? ( >=net-libs/gnutls-1.2.9 )
		!gnutls? ( dev-libs/openssl ) )
	ares? ( >=net-dns/c-ares-1.5.0 )
	bittorrent? (
		gnutls? ( >=net-libs/gnutls-1.2.9 >=dev-libs/libgcrypt-1.2.2 )
		!gnutls? ( dev-libs/openssl ) )
	metalink? (
		!expat? ( >=dev-libs/libxml2-2.6.26 )
		expat? ( dev-libs/expat ) )
	sqlite? ( dev-db/sqlite:3 )
	xmlrpc? (
		!expat? ( >=dev-libs/libxml2-2.6.26 )
		expat? ( dev-libs/expat ) )"
DEPEND="${CDEPEND}
	dev-util/pkgconfig
	nls? ( sys-devel/gettext )
	test? ( >=dev-util/cppunit-1.12.0 )"
RDEPEND="${CDEPEND}
	scripts? ( dev-lang/ruby )
	nls? ( virtual/libiconv virtual/libintl )"

pkg_setup() {
	if use scripts && use !xmlrpc && use !metalink; then
		ewarn "Please also enable the 'xmlrpc' USE flag to actually use the additional scripts"
	fi
}

src_prepare() {
	sed -i -e "s|/tmp|${T}|" test/*.cc test/*.txt || die "sed failed"
}

src_configure() {
	local myconf="--without-gnutls --without-openssl"
	use ssl && \
		myconf="$(use_with gnutls) $(use_with !gnutls openssl "${EPREFIX}"/usr/$(get_libdir))"

	local xmllib="--without-libexpat --without-libxml2"
	if use metalink || use xmlrpc ; then
		xmllib="$(use_with expat libexpat "${EPREFIX}"/usr/$(get_libdir)) $(use_with !expat libxml2)"
	fi 

	# Note:
	# - depends on libgcrypt only when using gnutls
	# - if --without-libexpat or --without-libxml2 are not given, it links against
	#   one of them to provide xmlrpc-functionality
	# - always enable gzip/http compression since zlib should always be available anyway
	# - always enable epoll since we can assume kernel 2.6.x
	# - other options for threads: solaris, pth, win32
	econf \
		--enable-epoll \
		--enable-threads=posix \
		--with-libz \
		$(use_enable nls) \
		$(use_enable metalink) \
		$(use_with sqlite sqlite3 "${EPREFIX}"/usr/$(get_libdir)) \
		$(use_enable bittorrent) \
		$(use_with ares libcares "${EPREFIX}"/usr/$(get_libdir)) \
		${xmllib} \
		${myconf}
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	rm -rf "${ED}/usr/share/doc/aria2"
	dodoc ChangeLog README AUTHORS NEWS
	dohtml README.html doc/aria2c.1.html

	use scripts && dobin doc/xmlrpc/aria2{mon,rpc}
}
