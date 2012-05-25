# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libwww/libwww-5.4.0-r7.ebuild,v 1.19 2012/05/05 02:54:28 jdhore Exp $

inherit eutils multilib autotools

PATCHVER="1.2"
MY_P=w3c-${P}

DESCRIPTION="A general-purpose client side WEB API"
HOMEPAGE="http://www.w3.org/Library/"
SRC_URI="http://www.w3.org/Library/Distribution/${MY_P}.tgz
	mirror://gentoo/${P}-patches-${PATCHVER}.tar.bz2"

LICENSE="W3C"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="mysql ssl"

RDEPEND=">=sys-libs/zlib-1.1.4
	mysql? ( virtual/mysql )
	ssl? ( >=dev-libs/openssl-0.9.6 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	dev-lang/perl"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	rm -f configure.in
	EPATCH_SUFFIX="patch" epatch "${WORKDIR}"/patch
	epatch "${FILESDIR}"/${P}-more-ssl-fixing.patch
	epatch "${FILESDIR}"/${P}-interix.patch
	eautoreconf
}

src_compile() {
	if use mysql; then
		myconf="--with-mysql=${EPREFIX}/usr/$(get_libdir)/mysql/libmysqlclient.a"
	else
		myconf="--without-mysql"
	fi

	export ac_cv_header_appkit_appkit_h=no
	econf \
		--enable-shared \
		--enable-static \
		--with-zlib \
		--with-md5 \
		--with-expat \
		$(use_with ssl) \
		${myconf}

	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc ChangeLog
	dohtml -r .
}
