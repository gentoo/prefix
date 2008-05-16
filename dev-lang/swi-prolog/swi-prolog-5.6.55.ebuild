# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/swi-prolog/swi-prolog-5.6.55.ebuild,v 1.1 2008/05/14 07:22:47 keri Exp $

EAPI="prefix"

inherit eutils flag-o-matic java-pkg-opt-2

PATCHSET_VER="0"

DESCRIPTION="free, small, and standard compliant Prolog compiler"
HOMEPAGE="http://www.swi-prolog.org/"
SRC_URI="http://gollem.science.uva.nl/cgi-bin/nph-download/SWI-Prolog/pl-${PV}.tar.gz
	mirror://gentoo/${P}-gentoo-patchset-${PATCHSET_VER}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="berkdb debug doc gmp hardened java minimal odbc readline ssl static latex threads zlib X"

DEPEND="!dev-lang/swi-prolog-lite
	sys-libs/ncurses
	zlib? ( sys-libs/zlib )
	odbc? ( dev-db/unixODBC )
	berkdb? ( sys-libs/db )
	readline? ( sys-libs/readline )
	gmp? ( dev-libs/gmp )
	ssl? ( dev-libs/openssl )
	java? ( >=virtual/jdk-1.4
		=dev-java/junit-3.8* )
	X? (
		media-libs/jpeg
		x11-libs/libX11
		x11-libs/libXft
		x11-libs/libXpm
		x11-libs/libXt
		x11-libs/libICE
		x11-libs/libSM
		x11-proto/xproto )"

S="${WORKDIR}/pl-${PV}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	EPATCH_FORCE=yes
	EPATCH_SUFFIX=patch
	epatch "${WORKDIR}"/${PV}
}

src_compile() {
	einfo "Building SWI-Prolog compiler"

	append-flags -fno-strict-aliasing
	use hardened && append-flags -fno-unit-at-a-time
	use debug && append-flags -DO_DEBUG

	local threadconf
	if use java && ! use minimal || use threads ; then
		threadconf="--enable-mt"
	else
		threadconf="--disable-mt"
	fi

	# ARCH is used in the configure script to figure out host and target
	# specific stuff
	export ARCH=${CHOST}

	cd "${S}"/src
	econf \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		${threadconf} \
		$(use_enable gmp) \
		$(use_enable readline) \
		$(use_enable !static shared) \
		--enable-custom-flags COFLAGS="${CFLAGS}" \
		|| die "econf failed"
	emake || die "emake failed"

	if ! use minimal ; then
		einfo "Building SWI-Prolog additional packages"

		cd "${S}/packages"
		econf \
			--libdir="${EPREFIX}"/usr/$(get_libdir) \
			${threadconf} \
			$(use_enable !static shared) \
			--without-C-sicstus \
			--with-chr \
			--with-clib \
			--with-clpqr \
			--with-cpp \
			--with-cppproxy \
			$(use_with berkdb db) \
			--with-http \
			--without-jasmine \
			$(use_with java jpl) \
			$(use_with latex ltx2htm) \
			--with-nlp \
			$(use_with odbc) \
			--with-pldoc \
			--with-plunit \
			--with-semweb \
			--with-sgml \
			--with-sgml/RDF \
			$(use_with ssl) \
			--with-table \
			$(use_with X xpce) \
			$(use_with zlib) \
			COFLAGS='"${CFLAGS}"' \
			|| die "packages econf failed"

		emake || die "packages emake failed"
	fi
}

src_install() {
	emake -C src DESTDIR="${D}" install || die "install src failed"

	if ! use minimal ; then
		emake -C packages DESTDIR="${D}" install || die "install packages failed"
		if use doc ; then
			emake -C packages DESTDIR="${D}" html-install || die "html-install failed"
			emake -C packages/cppproxy DESTDIR="${D}" install-examples || die "install-examples failed"
		fi
	fi

	dodoc ANNOUNCE ChangeLog INSTALL INSTALL.notes PORTING README README.GUI VERSION
}

src_test() {
	cd "${S}/src"
	emake check || die "make check failed. See above for details."

	if ! use minimal ; then
		cd "${S}/packages"
		emake check || die "make check failed. See above for details."
	fi
}
