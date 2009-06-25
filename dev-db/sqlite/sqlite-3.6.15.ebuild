# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/sqlite/sqlite-3.6.15.ebuild,v 1.1 2009/06/21 00:33:56 arfrever Exp $

EAPI="2"

inherit eutils flag-o-matic multilib versionator

DESCRIPTION="an SQL Database Engine in a C Library"
HOMEPAGE="http://www.sqlite.org/"
SRC_URI="http://www.sqlite.org/${P}.tar.gz"

LICENSE="as-is"
SLOT="3"
KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="debug soundex tcl +threadsafe"
RESTRICT="!tcl? ( test )"

RDEPEND="tcl? ( dev-lang/tcl )"
DEPEND="${RDEPEND}"

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

src_prepare() {
	# note: this sandbox fix is no longer needed with sandbox-1.3+
	epatch "${FILESDIR}"/sandbox-fix2.patch

	epatch "${FILESDIR}"/${PN}-3.6.2-interix.patch
	epatch "${FILESDIR}"/${PN}-3.6.11-interix.patch

	epunt_cxx
}

src_configure() {
	# Enable column metadata, bug #266651
	append-cppflags -DSQLITE_ENABLE_COLUMN_METADATA

	# not available via configure and requested in bug #143794
	use soundex && append-cppflags -DSQLITE_SOUNDEX

	econf \
		$(use_enable debug) \
		$(use_enable threadsafe) \
		$(use_enable threadsafe cross-thread-connections) \
		$(use_enable tcl) \
		$(use_enable tcl amalgamation) \
		--with-readline-inc=-I"${EPREFIX}"/usr/include/readline
}

src_compile() {
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

	doman sqlite3.1 || die "doman sqlite3.1 failed"
}
