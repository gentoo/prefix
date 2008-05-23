# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/sqlite/sqlite-3.4.1.ebuild,v 1.9 2007/12/11 09:43:02 vapier Exp $

EAPI="prefix"

inherit flag-o-matic eutils alternatives libtool

DESCRIPTION="an SQL Database Engine in a C Library"
HOMEPAGE="http://www.sqlite.org/"
SRC_URI="http://www.sqlite.org/${P}.tar.gz"

LICENSE="as-is"
SLOT="3"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="debug doc nothreadsafe soundex tcl"
RESTRICT="!tcl? ( test )"

DEPEND="doc? ( dev-lang/tcl )
	tcl? ( dev-lang/tcl )"
RDEPEND="tcl? ( dev-lang/tcl )"

SOURCE="/usr/bin/lemon"
ALTERNATIVES="${SOURCE}-3 ${SOURCE}-0"

src_unpack() {
	# test
	if has test ${FEATURES}; then
		if ! has userpriv ${FEATURES}; then
			ewarn "The userpriv feature must be enabled to run tests."
			eerror "Testsuite will not be run."
		fi
		if ! use tcl; then
			ewarn "You must enable the tcl use flag if you want to run the test"
			ewarn "suite."
			eerror "Testsuite will not be run."
		fi
	fi

	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/sandbox-fix2.patch

	# Respect LDFLAGS wrt bug #156299
	sed -i -e 's/^LTLINK = .*/& $(LDFLAGS)/' Makefile.in

	elibtoolize
	epunt_cxx
}

src_compile() {
	# not available via configure and requested in bug #143794
	use soundex && append-flags -DSQLITE_SOUNDEX=1

	econf ${myconf} \
		$(use_enable debug) \
		$(use_enable !nothreadsafe threadsafe) \
		$(use_enable !nothreadsafe cross-thread-connections) \
		$(use_enable tcl) \
		|| die "econf failed"

	emake all || die "emake all failed"

	if use doc ; then
		emake doc || die "emake doc failed"
	fi
}

src_test() {
	if use tcl ; then
		if has userpriv ${FEATURES} ; then
			cd "${S}"
			if use debug ; then
				emake fulltest || die "some test failed"
			else
				emake test || die "some test failed"
			fi
		fi
	fi
}

src_install () {
	make \
		DESTDIR="${D}" \
		TCLLIBDIR="${EPREFIX}/usr/$(get_libdir)" \
		install \
		|| die "make install failed"

	newbin lemon lemon-${SLOT} || die

	dodoc README VERSION || die
	doman sqlite3.1 || die

	use doc && dohtml doc/* art/*.gif
}
