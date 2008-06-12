# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cppunit/cppunit-1.12.1.ebuild,v 1.1 2008/03/15 17:39:45 dev-zero Exp $

EAPI="prefix"

#WANT_AUTOCONF=latest
#WANT_AUTOMAKE=1.9

inherit eutils autotools qt3

DESCRIPTION="C++ port of the famous JUnit framework for unit testing"
HOMEPAGE="http://cppunit.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="doc examples qt3"

RDEPEND="qt3? ( $(qt_min_version 3.3) )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen
	media-gfx/graphviz )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PN}-1.10.2-asneeded.patch"

	sed -i \
		-e 's|-L\($${CPPUNIT_LIB_DIR}\)|\1|' \
		-e 's|\(../../lib\)|-L\1 -L../../src/cppunit/.libs|' \
		examples/qt/qt_example.pro || die "sed failed"

	AT_M4DIR="${S}/config"
	eautomake
	elibtoolize
}

src_compile() {
	# Anything else than -O0 breaks on alpha
	use alpha && replace-flags "-O?" -O0

	econf \
		$(use_enable doc doxygen) \
		$(use_enable doc dot) \
		--htmldir="${EPREFIX}"/usr/share/doc/${PF}/html \
		|| die "econf failed"
	emake || die "emake failed"

	if use qt3 ; then
		cd src/qttestrunner
		eqmake3 qttestrunnerlib.pro || die "qmake failed"
		emake || die "emake failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog BUGS NEWS README THANKS TODO doc/FAQ

	if use qt3 ; then
		dolib lib/*
	fi

	if use examples ; then
		find examples -iname "*.o" -delete
		insinto /usr/share/${PN}
		doins -r examples
	fi
}
