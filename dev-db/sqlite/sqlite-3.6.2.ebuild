# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/sqlite/sqlite-3.6.2.ebuild,v 1.1 2008/09/15 16:50:14 betelgeuse Exp $

EAPI="prefix 1"

inherit versionator eutils flag-o-matic libtool autotools

DESCRIPTION="an SQL Database Engine in a C Library"
HOMEPAGE="http://www.sqlite.org/"
DOC_PV=$(replace_all_version_separators _)
SRC_URI="http://www.sqlite.org/${P}.tar.gz
	doc? ( http://www.sqlite.org/${PN}_docs_${DOC_PV}.zip )"

LICENSE="as-is"
SLOT="3"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="debug doc soundex tcl +threadsafe"
RESTRICT="!tcl? ( test )"

RDEPEND="tcl? ( dev-lang/tcl )"
DEPEND="${RDEPEND}
	doc? ( app-arch/unzip )"

pkg_setup() {
	# test
	if has test ${FEATURES}; then
		if ! has userpriv ${FEATURES}; then
			ewarn "The userpriv feature must be enabled to run tests."
			eerror "Testsuite will not be run."
		fi
		if ! use tcl; then
			ewarn "You must enable the tcl use flag if you want to run the testsuite."
			eerror "Testsuite will not be run."
		fi
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/sandbox-fix2.patch

	eautoreconf # need new libtool for interix
	epunt_cxx
}

src_compile() {
	# not available via configure and requested in bug #143794
	use soundex && append-flags -DSQLITE_SOUNDEX=1

	econf \
		$(use_enable debug) \
		$(use_enable threadsafe) \
		$(use_enable threadsafe cross-thread-connections) \
		$(use_enable tcl) \
		$(use_enable tcl amalgamation) \
		--with-readline-inc=-I"${EPREFIX}"/usr/include/readline \
		|| die
	emake all || die "emake all failed"
}

src_test() {
	if has userpriv ${FEATURES}; then
		local test=test
		use debug && tets=fulltest
		emake ${test} || die "some test(s) failed"
	fi
}

src_install() {
	emake \
		DESTDIR="${D}" \
		TCLLIBDIR="${EPREFIX}/usr/$(get_libdir)" \
		install \
		|| die "emake install failed"

	doman sqlite3.1 || die

	if use doc; then
		dohtml -r "${WORKDIR}"/${PN}_docs_${DOC_PV}/* || die
	fi
}

pkg_postinst() {
	elog "sqlite-3.6.0 is not totally backwards compatible, see"
	elog "http://www.sqlite.org/releaselog/3_6_0.html for full details."
}
