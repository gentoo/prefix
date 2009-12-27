# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/redland/redland-1.0.10-r1.ebuild,v 1.1 2009/12/18 13:42:26 ssuominen Exp $

EAPI=2
inherit autotools eutils

DESCRIPTION="High-level interface for the Resource Description Framework"
HOMEPAGE="http://librdf.org/"
SRC_URI="http://download.librdf.org/source/${P}.tar.gz"

LICENSE="Apache-2.0 GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="berkdb iodbc mysql postgres sqlite ssl threads xml"

RDEPEND="mysql? ( virtual/mysql )
	sqlite? ( =dev-db/sqlite-3* )
	berkdb? ( sys-libs/db )
	xml? ( dev-libs/libxml2 )
	!xml? ( dev-libs/expat )
	ssl? ( dev-libs/openssl )
	>=media-libs/raptor-1.4.17
	>=dev-libs/rasqal-0.9.16
	postgres? ( virtual/postgresql-base )
	iodbc? ( dev-db/libiodbc )"
DEPEND="${RDEPEND}
	>=sys-devel/libtool-2
	dev-util/gtk-doc-am
	dev-util/pkgconfig"

src_prepare() {
	epatch "${FILESDIR}"/${P}-librdf_storage_register_factory.patch

	sed -i \
		-e '/SHAVE/d' configure.ac || die
	eautoreconf
}

src_configure() {
	local parser="expat"

	use xml && parser="libxml"

	econf \
		--disable-dependency-tracking \
		$(use_with berkdb bdb) \
		--with-xml-parser=${parser} \
		$(use_with ssl openssl-digests) \
		$(use_with mysql) \
		$(use_with sqlite) \
		$(use_with postgres postgresql) \
		$(use_with iodbc virtuoso) \
		$(use_with threads) \
		--with-html-dir=/usr/share/doc/${PF}/html
}

src_test() {
	# Remove this hack from next release.
	if use threads; then
		ewarn "Test suite is known to be broken with USE threads, skipping."
	else
		emake check || die
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README TODO
	dohtml {FAQS,NEWS,README,RELEASE,TODO}.html
}
