# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/redland/redland-1.0.9-r1.ebuild,v 1.4 2009/09/25 10:47:13 maekke Exp $

EAPI=2
inherit autotools eutils libtool

DESCRIPTION="High-level interface for the Resource Description Framework"
HOMEPAGE="http://librdf.org"
SRC_URI="http://download.librdf.org/source/${P}.tar.gz"

LICENSE="LGPL-2.1 Apache-2.0"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="berkdb mysql postgres sqlite ssl threads xml"

RDEPEND="mysql? ( virtual/mysql )
	sqlite? ( =dev-db/sqlite-3* )
	berkdb? ( sys-libs/db )
	xml? ( dev-libs/libxml2 )
	!xml? ( dev-libs/expat )
	ssl? ( dev-libs/openssl )
	>=media-libs/raptor-1.4.16
	>=dev-libs/rasqal-0.9.16
	postgres? ( virtual/postgresql-base )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/gtk-doc-am
	>=sys-devel/libtool-2"

src_prepare() {
	epatch "${FILESDIR}"/${P}-ldflags.patch \
		"${FILESDIR}"/${P}-sqlite.patch \
		"${FILESDIR}"/${P}-librdf_storage_register_factory.patch
	eautoreconf
}

src_configure() {
	local myconf

	if use xml; then
		myconf="${myconf} --with-xml-parser=libxml"
	else
		myconf="${myconf} --with-xml-parser=expat"
	fi

	econf --with-raptor=system \
		--with-rasqal=system \
		$(use_with berkdb bdb) \
		$(use_with ssl openssl-digests) \
		$(use_with mysql) \
		$(use_with threads) \
		$(use_with sqlite) \
		$(use_with postgres postgresql) \
		${myconf}
}

src_test() {
	if ! use berkdb; then
		export REDLAND_TEST_CLONING_STORAGE_TYPE=hashes
		export REDLAND_TEST_CLONING_STORAGE_NAME=test
		export REDLAND_TEST_CLONING_STORAGE_OPTIONS="hash-type='memory',dir='.',write='yes',new='yes',contexts='yes'"
	fi
	default
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog* NEWS NOTICE README TODO
	dohtml {FAQS,NEWS,README,RELEASE,TODO}.html
}
