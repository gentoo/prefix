# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/openjade/openjade-1.3.2-r3.ebuild,v 1.9 2011/05/14 14:51:25 angelos Exp $

EAPI=2

inherit autotools sgml-catalog eutils flag-o-matic multilib

DESCRIPTION="Jade is an implementation of DSSSL - an ISO standard for formatting SGML and XML documents"
HOMEPAGE="http://openjade.sourceforge.net"
SRC_URI="mirror://sourceforge/openjade/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="static-libs"

RDEPEND="app-text/sgml-common
	>=app-text/opensp-1.5.1"
DEPEND="dev-lang/perl
	${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${P}-deplibs.patch \
		"${FILESDIR}"/${P}-ldflags.patch \
		"${FILESDIR}"/${P}-msggen.pl.patch \
		"${FILESDIR}"/${P}-respect-ldflags.patch \
		"${FILESDIR}"/${P}-libosp-la.patch \
		"${FILESDIR}"/${P}-gcc46.patch

	epatch "${FILESDIR}"/${P}-darwin.patch

	if [[ ${CHOST} == *-interix* ]] ; then
		# this adds a m4 file containing the two macros which are
		# otherwise missing (to keep down dependencies).
		EPATCH_OPTS="-p1" epatch "${FILESDIR}"/${P}-bootstrap.patch

		# this one disables multi byte chars for interix (support broken)
		epatch "${FILESDIR}"/${P}-interix.patch

		ln -s config/configure.in configure.in
		AT_M4DIR="jade spgrove style config" eautoreconf # need new libtool for interix
		# NOTE: eautoreconf here breaks other platforms
	fi

	# Please note!  Opts are disabled.  If you know what you're doing
	# feel free to remove this line.  It may cause problems with
	# docbook-sgml-utils among other things.
	ALLOWED_FLAGS="-O -O1 -O2 -pipe -g -march"
	strip-flags

	# Default CFLAGS and CXXFLAGS is -O2 but this make openjade segfault
	# on hppa. Using -O1 works fine. So I force it here.
	use hppa && replace-flags -O2 -O1

	SGML_PREFIX="${EPREFIX}"/usr/share/sgml
}

src_configure() {
	# Needed at least on Mac OS X 10.6, bug #287358
	export CONFIG_SHELL="${EPREFIX}"/bin/bash
	econf \
		--enable-http \
		--enable-default-catalog="${EPREFIX}"/etc/sgml/catalog \
		--enable-default-search-path="${EPREFIX}"/usr/share/sgml \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--datadir="${EPREFIX}"/usr/share/sgml/${P} \
		$(use_enable static-libs static)
}

src_compile() {
	emake -j1 || die "make failed"
}

src_install() {
	insinto /usr/$(get_libdir)

	make DESTDIR="${D}" \
		libdir="${EPREFIX}"/usr/$(get_libdir) \
		install install-man || die "make install failed"

	dosym openjade  /usr/bin/jade
	dosym onsgmls   /usr/bin/nsgmls
	dosym osgmlnorm /usr/bin/sgmlnorm
	dosym ospam     /usr/bin/spam
	dosym ospent    /usr/bin/spent
	dosym osx       /usr/bin/sgml2xml

	insinto /usr/share/sgml/${P}/
	doins dsssl/builtins.dsl

	echo 'SYSTEM "builtins.dsl" "builtins.dsl"' > ${ED}/usr/share/sgml/${P}/catalog
	insinto /usr/share/sgml/${P}/dsssl
	doins dsssl/{dsssl.dtd,style-sheet.dtd,fot.dtd}
	newins "${FILESDIR}"/${P}.dsssl-catalog catalog
# Breaks sgml2xml among other things
#	insinto /usr/share/sgml/${P}/unicode
#	doins unicode/{catalog,unicode.sd,unicode.syn,gensyntax.pl}
	insinto /usr/share/sgml/${P}/pubtext
	doins pubtext/*

	dodoc NEWS README VERSION
	dohtml doc/*.htm

	insinto /usr/share/doc/${PF}/jadedoc
	doins jadedoc/*.htm
	insinto /usr/share/doc/${PF}/jadedoc/images
	doins jadedoc/images/*
}

sgml-catalog_cat_include "/etc/sgml/${P}.cat" \
	"/usr/share/sgml/openjade-${PV}/catalog"
sgml-catalog_cat_include "/etc/sgml/${P}.cat" \
	"/usr/share/sgml/openjade-${PV}/dsssl/catalog"
sgml-catalog_cat_include "/etc/sgml/sgml-docbook.cat" \
	"/etc/sgml/${P}.cat"
