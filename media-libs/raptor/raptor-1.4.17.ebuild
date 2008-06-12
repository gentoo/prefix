# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/raptor/raptor-1.4.17.ebuild,v 1.2 2008/05/12 09:39:42 aballier Exp $

EAPI="prefix"

inherit eutils flag-o-matic

DESCRIPTION="The RDF Parser Toolkit"
HOMEPAGE="http://librdf.org/raptor"
SRC_URI="http://download.librdf.org/source/${P}.tar.gz"

LICENSE="LGPL-2.1 Apache-2.0"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="curl unicode xml"

RDEPEND="unicode? ( >=dev-libs/glib-2 )
	xml? ( >=dev-libs/libxml2-2.6.8 )
	!xml? ( dev-libs/expat )
	curl? ( net-misc/curl )
	dev-libs/libxslt"
DEPEND="${RDEPEND}
	sys-devel/flex
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epunt_cxx
}

src_compile() {
	local myconf=""

	if use xml; then
		myconf="${myconf} --with-xml-parser=libxml"
	else
		myconf="${myconf} --with-xml-parser=expat"
	fi
	# libtool needs help to find {libxml2,expat}.la from our prefix
	append-ldflags -L${EPREFIX}/usr/$(get_libdir)

	if use curl; then
		myconf="${myconf} --with-www=curl"
	elif use xml; then
		myconf="${myconf} --with-www=xml"
	else
		myconf="${myconf} --with-www=none"
	fi

	econf $(use_enable unicode nfc-check) \
		${myconf}

	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS NOTICE README
	dohtml NEWS.html README.html RELEASE.html
}
