# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/sqlite/sqlite-3.6.11.ebuild,v 1.8 2009/04/27 15:53:03 jer Exp $

EAPI=1

inherit eutils flag-o-matic multilib versionator

DESCRIPTION="an SQL Database Engine in a C Library"
HOMEPAGE="http://www.sqlite.org/"
DOC_BASE="$(get_version_component_range 1-3)"
DOC_PV="$(replace_all_version_separators _ ${DOC_BASE})"
SRC_URI="http://www.sqlite.org/${P}.tar.gz
	doc? ( http://www.sqlite.org/${PN}_docs_${DOC_PV}.zip )"

LICENSE="as-is"
SLOT="3"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="debug doc soundex tcl +threadsafe"
RESTRICT="!tcl? ( test )"

RDEPEND="tcl? ( dev-lang/tcl )"
DEPEND="${RDEPEND}
	doc? ( app-arch/unzip )"

pkg_setup() {
	if has test ${FEATURES} ; then
		if ! has userpriv ${FEATURES} ; then
			ewarn "The userpriv feature must be enabled to run tests."
			eerror "Testsuite will not be run."
		fi
		if ! use tcl ; then
			ewarn "You must enable the tcl use flag if you want to run the testsuite."
			eerror "Testsuite will not be run."
		fi
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# note: this sandbox fix is no longer needed with sandbox-1.3+
	epatch "${FILESDIR}"/sandbox-fix2.patch
	epatch "${FILESDIR}"/${P}-reference.patch

	epatch "${FILESDIR}"/${PN}-3.6.2-interix.patch
	epatch "${FILESDIR}"/${P}-interix.patch

	# avoid having to run autotools
	sed -i 's:3\.6\.10:3.6.11:g' configure
	epunt_cxx
}

src_compile() {
	# not available via configure and requested in bug #143794
	use soundex && append-cppflags -DSQLITE_SOUNDEX=1

	econf \
		$(use_enable debug) \
		$(use_enable threadsafe) \
		$(use_enable threadsafe cross-thread-connections) \
		$(use_enable tcl) \
		$(use_enable tcl amalgamation) \
		--with-readline-inc=-I"${EPREFIX}"/usr/include/readline
	emake TCLLIBDIR="${EPREFIX}/usr/$(get_libdir)/${P}" || die "emake failed"
}

src_test() {
	if has userpriv ${FEATURES} ; then
		local test=test
		use debug && test=fulltest
		emake ${test} || die "some test(s) failed"
	fi
}

src_install() {
	emake \
		DESTDIR="${D}" \
		TCLLIBDIR="${EPREFIX}/usr/$(get_libdir)/${P}" \
		install \
		|| die "emake install failed"

	doman sqlite3.1 || die

	if use doc ; then
		# Naming scheme changes randomly between - and _ in releases
		# http://www.sqlite.org/cvstrac/tktview?tn=3523
		dohtml -r "${WORKDIR}"/${PN}-${DOC_PV}-docs/* || die
	fi
}

pkg_postinst() {
	elog "sqlite-3.6.X is not totally backwards compatible, see"
	elog "http://www.sqlite.org/releaselog/3_6_0.html for full details."
}
