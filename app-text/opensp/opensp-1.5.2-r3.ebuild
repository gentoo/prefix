# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/opensp/opensp-1.5.2-r3.ebuild,v 1.4 2012/04/26 22:37:06 aballier Exp $

EAPI=2
inherit eutils flag-o-matic autotools

MY_P=${P/opensp/OpenSP}
DESCRIPTION="A free, object-oriented toolkit for SGML parsing and entity management"
HOMEPAGE="http://openjade.sourceforge.net/"
SRC_URI="mirror://sourceforge/openjade/${MY_P}.tar.gz"

LICENSE="JamesClark"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc nls static-libs test"

DEPEND="nls? ( >=sys-devel/gettext-0.14.5 )
	doc? (
		app-text/xmlto
		app-text/docbook-xml-dtd:4.1.2
	)
	test? (
		app-text/openjade
		app-text/sgml-common
	)"
RDEPEND=""

S=${WORKDIR}/${MY_P}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.5-gcc34.patch
	epatch "${FILESDIR}"/${P}-fix-segfault.patch
	
	# multibyte char support is broken on interix!
	[[ ${CHOST} == *-interix* ]] && epatch "${FILESDIR}"/${P}-interix.patch

	eautoreconf # need new libtool for interix
}

src_configure() {
	#
	# The following filters are taken from openjade's ebuild. See bug #100828.
	#

	# Please note!  Opts are disabled.  If you know what you're doing
	# feel free to remove this line.  It may cause problems with
	# docbook-sgml-utils among other things.
	ALLOWED_FLAGS="-O -O1 -O2 -pipe -g -march"
	strip-flags

	econf \
		--disable-dependency-tracking \
		--enable-http \
		--enable-default-catalog=${EPREFIX}/etc/sgml/catalog   \
		--enable-default-search-path=${EPREFIX}/usr/share/sgml \
		--datadir=${EPREFIX}/usr/share/sgml/${P}               \
		$(use_enable nls) \
		$(use_enable doc doc-build) \
		$(use_enable static-libs static)
}

src_compile() {
	emake pkgdocdir="${EPREFIX}"/usr/share/doc/${PF} || die "Compilation failed"
}

src_test() {
	echo ">>> Test phase [check]: ${CATEGORY}/${PF}"
	einfo "Skipping tests known not to work"
	make SHOWSTOPPERS= check || die "Make test failed"
	SANDBOX_PREDICT="${SANDBOX_PREDICT%:/}"
}

src_install() {
	emake DESTDIR="${D}" \
		pkgdocdir="${EPREFIX}"/usr/share/doc/${PF} install || die "Installation failed"

	dodoc AUTHORS BUGS ChangeLog NEWS README
}

pkg_postinst() {
	ewarn "Please note that the soname of the library changed."
	ewarn "If you are upgrading from a previous version you need"
	ewarn "to fix dynamic linking inconsistencies by executing:"
	ewarn
	ewarn "    revdep-rebuild --library='libosp.so.*'"
}
