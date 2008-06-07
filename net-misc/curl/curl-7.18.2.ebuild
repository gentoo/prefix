# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/curl/curl-7.18.2.ebuild,v 1.1 2008/06/07 04:38:07 dragonheart Exp $

EAPI="prefix"

# NOTE: If you bump this ebuild, make sure you bump dev-python/pycurl!

inherit libtool autotools flag-o-matic

#MY_P=${P/_pre/-}
DESCRIPTION="A Client that groks URLs"
HOMEPAGE="http://curl.haxx.se/ http://curl.planetmirror.com"
#SRC_URI="http://cool.haxx.se/curl-daily/${MY_P}.tar.bz2"
SRC_URI="http://curl.planetmirror.com/download/${P}.tar.bz2"

LICENSE="MIT X11"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
#IUSE="ssl ipv6 ldap ares gnutls nss idn kerberos test"
IUSE="ssl ipv6 ldap ares gnutls libssh2 nss idn kerberos test"

# TODO - change to openssl USE flag in the not too distant future
# https://bugs.gentoo.org/show_bug.cgi?id=207653#c3 (April 2008)

RDEPEND="gnutls? ( net-libs/gnutls app-misc/ca-certificates )
	nss? ( !gnutls? ( dev-libs/nss app-misc/ca-certificates ) )
	ssl? ( !gnutls? ( !nss? ( dev-libs/openssl app-misc/ca-certificates ) ) )
	ldap? ( net-nds/openldap )
	idn? ( net-dns/libidn )
	ares? ( >=net-dns/c-ares-1.4.0 )
	kerberos? ( virtual/krb5 )
	libssh2? ( >=net-libs/libssh2-0.16 )"

# fbopenssl (not in gentoo) --with-spnego
# krb4 http://web.mit.edu/kerberos/www/krb4-end-of-life.html

DEPEND="${RDEPEND}
	test? (
		sys-apps/diffutils
		dev-lang/perl
	)"
# used - but can do without in self test: net-misc/stunnel
#S="${WORKDIR}"/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/curl-7.17.0-strip-ldflags.patch
	# below: bug #216096
	sed -i -e 's:gssapi/gssapi.h:gssapi/gssapi_generic.h:g' configure.ac
	eautoreconf
}

src_compile() {
	[[ ${CHOST} == *-interix* ]] && {
		append-flags -D_ALL_SOURCE
		export ac_cv_func_poll=no
		export skipcheck_poll=yes
	}

	myconf="$(use_enable ldap)
		$(use_enable ldap ldaps)
		$(use_with idn libidn)
		$(use_with kerberos gssapi /usr)
		$(use_with libssh2)
		$(use_enable ipv6)
		--enable-http
		--enable-ftp
		--enable-gopher
		--enable-file
		--enable-dict
		--enable-manual
		--enable-telnet
		--enable-nonblocking
		--enable-largefile
		--enable-maintainer-mode
		--disable-sspi
		--without-krb4
		--without-spnego"

	if use ipv6 && use ares; then
		elog "c-ares support disabled because it is incompatible with ipv6."
		myconf="${myconf} --disable-ares"
	else
		myconf="${myconf} $(use_enable ares)"
	fi

	if use gnutls; then
		myconf="${myconf} --without-ssl --with-gnutls --without-nss"
		myconf="${myconf} --with-ca-bundle=/etc/ssl/certs/ca-certificates.crt"
	elif use nss; then
		myconf="${myconf} --without-ssl --without-gnutls --with-nss"
		myconf="${myconf} --with-ca-bundle=/etc/ssl/certs/ca-certificates.crt"
	elif use ssl; then
		myconf="${myconf} --without-gnutls --without-nss --with-ssl"
		myconf="${myconf} --without-ca-bundle --with-ca-path=/etc/ssl/certs"
	else
		myconf="${myconf} --without-gnutls --without-nss --without-ssl"
	fi

	econf ${myconf} || die 'configure failed'

	emake || die "install failed for current version"
}

src_install() {
	emake DESTDIR="${D}" install || die "installed failed for current version"
	rm -rf "${ED}"/etc/

	# https://sourceforge.net/tracker/index.php?func=detail&aid=1705197&group_id=976&atid=350976
	insinto /usr/share/aclocal
	doins docs/libcurl/libcurl.m4

	dodoc CHANGES README
	dodoc docs/FEATURES docs/INTERNALS
	dodoc docs/MANUAL docs/FAQ docs/BUGS docs/CONTRIBUTE
}

pkg_postinst() {
	if [[ -e "${EROOT}"/usr/$(get_libdir)/libcurl.so.3 ]] ; then
		elog "You must re-compile all packages that are linked against"
		elog "curl-7.15.* by using revdep-rebuild from gentoolkit:"
		elog "# revdep-rebuild --library libcurl.so.3"
	fi
}
