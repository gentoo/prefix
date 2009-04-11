# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/neon/neon-0.28.4.ebuild,v 1.1 2009/03/21 21:52:20 arfrever Exp $

inherit autotools eutils libtool versionator

RESTRICT="test"

DESCRIPTION="HTTP and WebDAV client library"
HOMEPAGE="http://www.webdav.org/neon/"
SRC_URI="http://www.webdav.org/neon/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc expat gnutls kerberos nls pkcs11 socks5 ssl zlib"
IUSE_LINGUAS="cs de fr ja nn pl ru tr zh_CN"
for lingua in ${IUSE_LINGUAS}; do
	IUSE="${IUSE} linguas_${lingua}"
done

RDEPEND="expat? ( dev-libs/expat )
	!expat? ( dev-libs/libxml2 )
	gnutls? (
		>=net-libs/gnutls-2.0
		pkcs11? ( dev-libs/pakchois )
	)
	!gnutls? ( ssl? (
		>=dev-libs/openssl-0.9.6f
		pkcs11? ( dev-libs/pakchois )
	) )
	kerberos? ( virtual/krb5 )
	nls? ( virtual/libintl )
	socks5? ( net-proxy/dante )
	zlib? ( sys-libs/zlib )"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	local lingua linguas
	for lingua in ${IUSE_LINGUAS}; do
		use linguas_${lingua} && linguas="${linguas} ${lingua}"
	done
	sed -i -e "s/ALL_LINGUAS=.*/ALL_LINGUAS=\"${linguas}\"/g" configure.in
	sed -i -e "s/socks5/socks/g" macros/neon.m4

	AT_M4DIR="macros" eautoreconf
}

src_compile() {
	local myconf

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

	if use gnutls; then
		myconf="${myconf} --with-ssl=gnutls"
	elif use ssl; then
		myconf="${myconf} --with-ssl=openssl"
	fi

	econf \
		--enable-static \
		--enable-shared \
		$(use_with kerberos gssapi) \
		$(use_enable nls) \
		$(use_with pkcs11 pakchois) \
		$(use_with socks5 socks) \
		$(use_with zlib) \
		${myconf}
	emake || die "emake failed"
}

src_test() {
	emake check || die "Trying make check without success."
}

src_install() {
	emake DESTDIR="${D}" install-lib install-headers install-config install-nls || die "emake install failed"

	if use doc; then
		emake DESTDIR="${D}" install-docs || die "emake install-docs failed"
	fi

	dodoc AUTHORS BUGS NEWS README THANKS TODO
	doman doc/man/*.[1-8]
}

pkg_postinst() {
	ewarn "Neon has a policy of breaking API across minor versions, this means"
	ewarn "that any package that links against neon may be broken after"
	ewarn "updating. They will remain broken until they are ported to the"
	ewarn "new API. You can downgrade neon to the previous version by doing:"
	ewarn
	ewarn "  emerge --oneshot '<net-misc/neon-$(get_version_component_range 1-2 ${PV})'"
	ewarn
	ewarn "You may also have to downgrade any package that has already been"
	ewarn "ported to the new API."
}
