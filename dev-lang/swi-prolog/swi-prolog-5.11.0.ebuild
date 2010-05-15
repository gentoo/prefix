# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/swi-prolog/swi-prolog-5.11.0.ebuild,v 1.1 2010/05/07 20:44:10 keri Exp $

inherit eutils flag-o-matic java-pkg-opt-2

PATCHSET_VER="0"

DESCRIPTION="free, small, and standard compliant Prolog compiler"
HOMEPAGE="http://www.swi-prolog.org/"
SRC_URI="http://www.swi-prolog.org/download/devel/src/pl-${PV}.tar.gz
	mirror://gentoo/${P}-gentoo-patchset-${PATCHSET_VER}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="berkdb debug doc gmp hardened java minimal odbc readline ssl static test zlib X"

RDEPEND="sys-libs/ncurses
	zlib? ( sys-libs/zlib )
	odbc? ( dev-db/unixODBC )
	berkdb? ( sys-libs/db )
	readline? ( sys-libs/readline )
	gmp? ( dev-libs/gmp )
	ssl? ( dev-libs/openssl )
	java? ( >=virtual/jdk-1.4 )
	X? (
		media-libs/jpeg
		x11-libs/libX11
		x11-libs/libXft
		x11-libs/libXpm
		x11-libs/libXt
		x11-libs/libICE
		x11-libs/libSM )"

DEPEND="${RDEPEND}
	X? ( x11-proto/xproto )
	java? ( test? ( =dev-java/junit-3.8* ) )"

S="${WORKDIR}/pl-${PV}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	EPATCH_FORCE=yes
	EPATCH_SUFFIX=patch
	epatch "${WORKDIR}"/${PV}
}

src_compile() {
	append-flags -fno-strict-aliasing
	use hardened && append-flags -fno-unit-at-a-time
	use debug && append-flags -DO_DEBUG

	# ARCH is used in the configure script to figure out host and target
	# specific stuff
	export ARCH=${CHOST}

	cd "${S}"/src
	econf \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		$(use_enable gmp) \
		$(use_enable readline) \
		$(use_enable !static shared) \
		--enable-custom-flags COFLAGS="${CFLAGS}" \
		|| die "econf failed"
	emake || die "emake failed"

	if ! use minimal ; then
		local jpltestconf
		if use java && use test ; then
			jpltestconf="--with-junit=$(java-config --classpath junit)"
		fi

		cd "${S}/packages"
		econf \
			--libdir="${EPREFIX}"/usr/$(get_libdir) \
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
			${jpltestconf} \
			--with-nlp \
			$(use_with odbc) \
			--with-pldoc \
			--with-plunit \
			--with-protobufs \
			--with-R \
			--with-RDF \
			--with-semweb \
			--with-sgml \
			$(use_with ssl) \
			--with-table \
			--with-tipc \
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

	dodoc ChangeLog INSTALL PORTING README VERSION
}

src_test() {
	cd "${S}/src"
	emake check || die "make check failed. See above for details."

	if ! use minimal ; then
		cd "${S}/packages"
		emake check || die "make check failed. See above for details."
	fi
}

pkg_postinst() {
	einfo "Please note that the following binaries have been renamed"
	einfo "from earlier versions:"
	einfo "    pl    ->  swipl"
	einfo "    plld  ->  swipl-ld"
	einfo "    plrc  ->  swipl-rc"
	einfo "    xpce  ->  <deleted>"
}
