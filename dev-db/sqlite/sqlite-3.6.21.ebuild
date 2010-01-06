# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/sqlite/sqlite-3.6.21.ebuild,v 1.6 2010/01/03 09:38:38 betelgeuse Exp $

EAPI="2"

inherit eutils flag-o-matic multilib versionator

DESCRIPTION="an SQL Database Engine in a C Library"
HOMEPAGE="http://www.sqlite.org/"
DOC_BASE="$(get_version_component_range 1-3)"
DOC_PV="$(replace_all_version_separators _ ${DOC_BASE})"

SRC_URI="
	tcl? ( http://www.sqlite.org/${P}.tar.gz )
	!tcl? (
		test? ( http://www.sqlite.org/${P}.tar.gz )
		!test? ( http://www.sqlite.org/${PN}-amalgamation-${PV}.tar.gz )
	)
	doc? ( http://www.sqlite.org/${PN}_docs_${DOC_PV}.zip )"

LICENSE="as-is"
SLOT="3"
KEYWORDS="~ppc-aix ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="debug doc +fts3 icu +readline soundex tcl +threadsafe test"

RDEPEND="icu? ( dev-libs/icu )
	readline? ( sys-libs/readline )
	tcl? ( dev-lang/tcl )"
DEPEND="${RDEPEND}
	test? ( dev-lang/tcl )
	doc? ( app-arch/unzip )"

src_prepare() {
	if use icu; then
		rm -f test/like.test
	fi

# fails to apply	epatch "${FILESDIR}"/${PN}-3.6.2-interix.patch
# fails to apply	epatch "${FILESDIR}"/${PN}-3.6.11-interix.patch

	epunt_cxx
}

src_configure() {
	# Support column metadata, bug #266651
	append-cppflags -DSQLITE_ENABLE_COLUMN_METADATA

	# Support R-trees, bug #257646
	append-cppflags -DSQLITE_ENABLE_RTREE

	if use icu; then
		append-cppflags -DSQLITE_ENABLE_ICU
		if use tcl || use test; then
			# Normal tarball.
			sed -e "s/TLIBS = @LIBS@/& -licui18n -licuuc/" -i Makefile.in || die "sed failed"
		else
			# Amalgamation tarball.
			sed -e "s/LIBS = @LIBS@/& -licui18n -licuuc/" -i Makefile.in || die "sed failed"
		fi
	fi

	# Support soundex, bug #143794
	if use soundex; then
		append-cppflags -DSQLITE_SOUNDEX
	fi

	# Support FTS3, bug #207701
	if use fts3; then
		append-cppflags -DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS
	fi

	# The amalgamation source doesn't have these via Makefile
	if use debug; then
		append-cppflags -DSQLITE_DEBUG=1
	else
		append-cppflags -DNDEBUG
	fi

	# amalgamation doesn't have tcl
	econf \
		$(use_enable readline) \
		--with-readline-inc=-I"${EPREFIX}"/usr/include/readline \
		$(use_enable threadsafe) \
		$(use tcl && echo --enable-tcl) \
		$(use !tcl && use test && echo --disable-tcl)
}

src_compile() {
	emake TCLLIBDIR="${EPREFIX}/usr/$(get_libdir)/${P}" || die "emake failed"
}

src_test() {
	if [[ "${EUID}" -ne "0" ]]; then
		local test="test"
		use debug && test="fulltest"
		emake ${test} || die "Some test(s) failed"
	else
		ewarn "The userpriv feature must be enabled to run tests."
		eerror "Testsuite will not be run."
	fi
}

src_install() {
	emake \
		DESTDIR="${D}" \
		TCLLIBDIR="${EPREFIX}/usr/$(get_libdir)/${P}" \
		install \
		|| die "emake install failed"

	doman sqlite3.1 || die "doman sqlite3.1 failed"

	if use doc; then
		# Naming scheme changes randomly between - and _ in releases
		# http://www.sqlite.org/cvstrac/tktview?tn=3523
		dohtml -r "${WORKDIR}"/${PN}-${DOC_PV}-docs/* || die "dohtml failed"
	fi
}
