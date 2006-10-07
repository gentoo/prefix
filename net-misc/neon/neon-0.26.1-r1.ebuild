# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/neon/neon-0.26.1-r1.ebuild,v 1.2 2006/10/01 16:10:28 gmsoft Exp $

EAPI="prefix"

inherit eutils libtool versionator

DESCRIPTION="HTTP and WebDAV client library"
HOMEPAGE="http://www.webdav.org/neon/"
SRC_URI="http://www.webdav.org/neon/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="expat nls socks5 ssl static zlib"

DEPEND="expat? ( dev-libs/expat )
	!expat? ( dev-libs/libxml2 )
	socks5? ( net-proxy/dante )
	zlib? ( sys-libs/zlib )
	ssl? ( >=dev-libs/openssl-0.9.6f )"

RESTRICT="test"

src_unpack() {
	unpack ${A}
	if use userland_Darwin ; then
		sed -i -e "s:GXX:GCC:g" ${S}/configure || die "sed failed"
	fi

	elibtoolize
}

src_compile() {
	local myconf=""
	if has_version sys-libs/glibc; then
		if built_with_use sys-libs/glibc nptlonly \
		    || built_with_use sys-libs/glibc nptl; then
		    einfo "Enabling SSL library thread-safety using POSIX threads..."
		    myconf="${myconf} --enable-threadsafe-ssl=posix"
		fi
	fi
	if use expat; then
	    myconf="${myconf} --with-expat"
	else
	    myconf="${myconf} --with-xml2"
	fi

	if use ssl; then
	    myconf="${myconf} --with-ssl=openssl"
	fi

	if ! use nls; then
	    myconf="${myconf} --disable-nls"
	fi

	if use static; then
	    myconf="${myconf} --enable-static"
	else
	    myconf="${myconf} --disable-static --with-pic"
	fi

	econf \
		--enable-shared \
		--without-gssapi \
		$(use_with zlib) \
		$(use_enable socks5 socks) \
		${myconf} \
		|| die "econf failed"
	emake || die "emake failed"
}

src_test() {
	cd ${S}
	make check || die "Trying make check without success."
}

src_install() {
	make DESTDIR="${EDEST}" install || die 'install failed'
	dodoc AUTHORS BUGS ChangeLog NEWS README THANKS TODO doc/*
}

pkg_postinst() {
	ewarn "There are new features in this version; please beware that"
	ewarn "upstream considers the socks support experimental.  If you"
	ewarn "experience test failures (eg, bug 135863) then try rebuilding"
	ewarn "glibc."
	ewarn
	ewarn "Neon has a policy of breaking API across versions, this means"
	ewarn "that any packages that link against neon will be broken after"
	ewarn "updating. They will remain broken until they are ported to the"
	ewarn "new API. You can downgrade neon to the previous version by doing:"
	ewarn
	ewarn "  emerge --oneshot '<net-misc/neon-$(get_version_component_range 1-2 ${PV})'"
	ewarn
	ewarn "You may also have to downgrade any packages that have already been"
	ewarn "ported to the new API."
}
