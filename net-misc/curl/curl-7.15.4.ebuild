# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/curl/curl-7.15.4.ebuild,v 1.1 2006/07/17 11:42:37 liquidx Exp $

EAPI="prefix"

# NOTE: If you bump this ebuild, make sure you bump dev-python/pycurl!

inherit libtool eutils

DESCRIPTION="A Client that groks URLs"
HOMEPAGE="http://curl.haxx.se/"
SRC_URI="http://curl.haxx.se/download/${P}.tar.bz2"

LICENSE="MIT X11"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="ssl ipv6 ldap ares gnutls idn kerberos krb4 test"

RDEPEND="gnutls? ( net-libs/gnutls )
	ssl? ( !gnutls? ( dev-libs/openssl ) )
	ldap? ( net-nds/openldap )
	idn? ( net-dns/libidn )
	ares? ( net-dns/c-ares )
	kerberos? ( virtual/krb5 )
	krb4? ( app-crypt/kth-krb )"

DEPEND="${RDEPEND}
	test? (
		sys-apps/diffutils
		dev-lang/perl
	)"
# used - but can do without in self test: net-misc/stunnel

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch ${FILESDIR}/${PN}-7.15-strip-ldflags.patch
	elibtoolize
}

src_compile() {

	myconf="$(use_enable ldap)
		$(use_with idn libidn)
		$(use_enable kerberos gssapi)
		$(use_enable ipv6)
		--enable-http
		--enable-ftp
		--enable-gopher
		--enable-file
		--enable-dict
		--enable-manual
		--enable-telnet
		--enable-nonblocking
		--enable-largefile"

	if use ipv6 && use ares; then
		ewarn "c-ares support disabled because it is incompatible with ipv6."
		myconf="${myconf} --disable-ares"
	else
		myconf="${myconf} $(use_enable ares)"
	fi

	if use ipv6 && use krb4; then
		ewarn "kerberos-4 support disabled because it is incompatible with ipv6."
		myconf="${myconf} --disable-krb4"
	else
		myconf="${myconf} $(use_enable krb4)"
	fi

	if use gnutls; then
		myconf="${myconf} --without-ssl --with-gnutls=${EPREFIX}/usr"
	elif use ssl; then
		myconf="${myconf} --without-gnutls --with-ssl=${EPREFIX}/usr"
	else
		myconf="${myconf} --without-gnutls --without-ssl"
	fi

	if use kerberos; then
	   myconf="${myconfg} --with-gssapi=${EPREFIX}/usr"
	fi

	econf ${myconf} || die 'configure failed'
	emake || die "install failed for current version"
}

src_install() {
	make DESTDIR="${EDEST}" install || die "installed failed for current version"

	insinto /usr/share/aclocal
	doins docs/libcurl/libcurl.m4

	dodoc CHANGES README
	dodoc docs/FEATURES docs/INTERNALS docs/LIBCURL
	dodoc docs/MANUAL docs/FAQ docs/BUGS docs/CONTRIBUTE
}
