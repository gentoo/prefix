# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/ossp-uuid/ossp-uuid-1.6.2-r1.ebuild,v 1.8 2012/05/12 18:30:44 aballier Exp $

EAPI="2"

PHP_EXT_NAME="uuid"
PHP_EXT_INI="yes"
PHP_EXT_ZENDEXT="no"
PHP_VERSION="5"

MY_P="uuid-${PV}"
PHP_EXT_S="${WORKDIR}/${MY_P}/php"
PHP_EXT_OPTIONAL_USE="php"
inherit eutils multilib php-ext-source-r2

DESCRIPTION="An ISO-C:1999 API and corresponding CLI for the generation of DCE 1.1, ISO/IEC 11578:1996 and RFC 4122 compliant UUID."
HOMEPAGE="http://www.ossp.org/pkg/lib/uuid/"
SRC_URI="ftp://ftp.ossp.org/pkg/lib/uuid/${MY_P}.tar.gz"
LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
IUSE="+cxx php"

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_prepare() {

	epatch "${FILESDIR}/${P}-gentoo-r1.patch"

	if use php; then
		local slot
		for slot in $(php_get_slots); do
	        php_init_slot_env ${slot}
			epatch "${FILESDIR}/${P}-gentoo-php.patch"
		done

		php-ext-source-r2_src_prepare
	fi
}

src_configure() {
	# Notes:
	# * collides with e2fstools libs and includes if not moved around
	# * perl-bindings are broken
	# * pgsql-bindings need PostgreSQL-sources and are included since PostgreSQL 8.3
	econf \
		--includedir="${EPREFIX}"/usr/include/ossp \
		--with-dce \
		--without-pgsql \
		--without-perl \
		--without-php \
		$(use_with cxx) \
		|| die "econf failed"
	if use php; then
		php-ext-source-r2_src_configure
	fi
}

src_compile() {
	emake || die "emake failed"

	if use php; then
		php-ext-source-r2_src_compile
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS BINDINGS ChangeLog HISTORY NEWS OVERVIEW PORTING README SEEALSO THANKS TODO USERS

	if use php ; then
		php-ext-source-r2_src_install
		cd "${S}/php"
		insinto /usr/share/php
		newins uuid.php5 uuid.php
	fi

	mv "${ED}/usr/$(get_libdir)/pkgconfig"/{,ossp-}uuid.pc
	mv "${ED}/usr/share/man/man3"/uuid.3{,ossp}
	mv "${ED}/usr/share/man/man3"/uuid++.3{,ossp}
}

src_test() {
	emake check || die "emake check failed"
	# Tests for the php-bindings would be available
}
