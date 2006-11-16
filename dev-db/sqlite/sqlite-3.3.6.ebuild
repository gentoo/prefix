# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/sqlite/sqlite-3.3.6.ebuild,v 1.6 2006/10/27 21:20:20 uberlord Exp $

EAPI="prefix"

inherit eutils alternatives

DESCRIPTION="SQLite: An SQL Database Engine in a C Library"
HOMEPAGE="http://www.sqlite.org/"
SRC_URI="http://www.sqlite.org/${P}.tar.gz"

LICENSE="as-is"
SLOT="3"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE="nothreadsafe doc tcl debug"

DEPEND="virtual/libc
	doc? ( dev-lang/tcl )
	tcl? ( dev-lang/tcl )"

SOURCE="/usr/bin/lemon"
ALTERNATIVES="${SOURCE}-3 ${SOURCE}-0"

src_unpack() {
	# test
	if has test ${FEATURES}; then
		if ! has userpriv ${FEATURES}; then
			ewarn "The userpriv feature must be enabled to run tests."
			ewarn "Testsuite will not be run."
		fi
		if ! use tcl; then
			ewarn "The tcl useflag must be enabled to run tests."
			ewarn "Testsuite will not be run."
		fi
	fi

	unpack ${A}

	cd ${P}
	epatch ${FILESDIR}/sqlite-3.3.3-tcl-fix.patch
	epatch ${FILESDIR}/sqlite-3-test-fix-3.3.4.patch

	epatch ${FILESDIR}/sandbox-fix1.patch
	epatch ${FILESDIR}/sandbox-fix2.patch

	# Fix broken tests that are not portable to 64 arches
	epatch ${FILESDIR}/sqlite-64bit-test-fix.patch
	epatch ${FILESDIR}/sqlite-64bit-test-fix2.patch
	epunt_cxx
}

src_compile() {
	local myconf

	myconf="--enable-incore-db --enable-tempdb-in-ram --enable-cross-thread-connections"

	if ! use nothreadsafe; then
		myconf="${myconf} --enable-threadsafe"
	else
		myconf="${myconf} --disable-threadsafe"
	fi

	if ! use tcl; then
		myconf="${myconf} --disable-tcl"
	fi

	if use debug; then
		myconf="${myconf} --enable-debug"
	fi

	econf ${myconf} || die
	emake all || die

	if use doc; then
		emake doc
	fi
}

src_test() {
	if use tcl ; then
		if has userpriv ${FEATURES} ; then
			cd ${S}
			if use debug; then
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
		install || die

	newbin lemon lemon-${SLOT}

	dodoc README VERSION
	doman sqlite3.1

	if use doc; then
		docinto html
		dohtml doc/*.html doc/*.txt doc/*.png
	fi
}
