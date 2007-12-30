# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/neon/neon-0.26.4.ebuild,v 1.5 2007/12/29 18:37:58 armin76 Exp $

EAPI="prefix"

inherit eutils libtool versionator autotools

DESCRIPTION="HTTP and WebDAV client library"
HOMEPAGE="http://www.webdav.org/neon/"
SRC_URI="http://www.webdav.org/neon/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ia64-hpux ~ppc-aix ~ppc-macos ~sparc-solaris ~sparc64-solaris ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"
IUSE="expat kerberos nls socks5 ssl zlib"
RESTRICT="test"

DEPEND="expat? ( dev-libs/expat )
	!expat? ( dev-libs/libxml2 )
	kerberos? ( virtual/krb5 )
	nls? ( virtual/libintl )
	socks5? ( net-proxy/dante )
	ssl? ( >=dev-libs/openssl-0.9.6f )
	zlib? ( sys-libs/zlib )"

src_unpack() {
	unpack ${A}
	elibtoolize
}

src_compile() {
	local myconf=

	if has_version sys-libs/glibc; then
		if built_with_use --missing true sys-libs/glibc nptlonly \
			|| built_with_use --missing true sys-libs/glibc nptl; then
			einfo "Enabling SSL library thread-safety using POSIX threads..."
			myconf="${myconf} --enable-threadsafe-ssl=posix"
		fi
	fi

	if use expat; then
		myconf="${myconf} --with-expat"
	else
		myconf="${myconf} --with-libxml2"
	fi

	if use ssl; then
		myconf="${myconf} --with-ssl=openssl"
	fi

	econf \
		--enable-static \
		--enable-shared \
		$(use_with zlib) \
		$(use_with kerberos gssapi) \
		$(use_enable socks5 socks) \
		$(use_enable nls) \
		${myconf} \
		|| die "econf failed"
	emake || die "emake failed"
}

src_test() {
	make check || die "Trying make check without success."
}

src_install() {
	make DESTDIR="${D}" install || die 'install failed'
	dodoc AUTHORS BUGS ChangeLog NEWS README THANKS TODO doc/*
}

pkg_postinst() {
	ewarn "There are new features in this version; please beware that"
	ewarn "upstream considers the socks support experimental.  If you"
	ewarn "experience test failures (eg, bug 135863) then try rebuilding"
	ewarn "glibc."
	ewarn
	ewarn "Neon has a policy of breaking API across versions, this means"
	ewarn "that any packages that links against neon will be broken after"
	ewarn "updating. They will remain broken until they are ported to the"
	ewarn "new API. You can downgrade neon to the previous version by doing:"
	ewarn
	ewarn "  emerge --oneshot '<net-misc/neon-$(get_version_component_range 1-2 ${PV})'"
	ewarn
	ewarn "You may also have to downgrade any packages that have already been"
	ewarn "ported to the new API."
}
