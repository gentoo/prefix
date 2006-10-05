# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libwww/libwww-5.4.0-r5.ebuild,v 1.1 2006/01/06 14:31:36 nattfodd Exp $

EAPI="prefix"

inherit eutils multilib autotools

MY_P=w3c-${P}
DESCRIPTION="A general-purpose client side WEB API"
HOMEPAGE="http://www.w3.org/Library/"
SRC_URI="http://www.w3.org/Library/Distribution/${MY_P}.tgz
	mirror://gentoo/libwww-5.4.0-debian-autoconf-2.5.patch.bz2"

LICENSE="W3C"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="mysql ssl"

RDEPEND=">=sys-libs/zlib-1.1.4
	mysql? ( >=dev-db/mysql-3.23.26 )
	ssl? ( >=dev-libs/openssl-0.9.6 )"

DEPEND="${RDEPEND}
	!dev-libs/9libs
	>=sys-devel/autoconf-2.13
	dev-lang/perl"

S=${WORKDIR}/${MY_P}


src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-config-liborder.patch
	epatch "${WORKDIR}"/${P}-debian-autoconf-2.5.patch
	epatch "${FILESDIR}"/${P}-autoconf-gentoo.diff
	epatch "${FILESDIR}"/${P}-automake-gentoo.diff	# bug #41959
	epatch "${FILESDIR}"/${P}-disable-ndebug-gentoo.diff	# bug #50483
	# http://lists.w3.org/Archives/Public/www-lib/2003OctDec/0015.html
	# http://www.mysql.gr.jp/mysqlml/mysql/msg/8118
	epatch "${FILESDIR}"/${P}-mysql-4.1.patch
	# Fix multiple problems, potentially exploitable (bug #109040)
	epatch "${FILESDIR}"/${P}-htbound.patch
	# Fix linking while using --as-needed
	epatch "${FILESDIR}/${P}-asneeded.patch"
	# Drop Externls rebuild after automake
	epatch "${FILESDIR}/${P}-noexport.patch"
	# Mac OS X has no automake 1.4, only 1.6.3
	epatch "${FILESDIR}/${P}-automake-macos.patch"

	eautoreconf || die "autoreconf failed"
}

src_compile() {
	if use mysql ; then
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
		${myconf} || die "./configure failed"

	emake || die "Compilation failed"
}

src_install() {
	make DESTDIR="${EDEST}" install || die "Installation failed"
	dodoc ChangeLog
	dohtml -r .
}
