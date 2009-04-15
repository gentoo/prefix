# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/xmlrpc-c/xmlrpc-c-1.16.06-r1.ebuild,v 1.4 2009/04/11 08:37:59 kumba Exp $

EAPI=1

inherit eutils multilib base

DESCRIPTION="A lightweigt RPC library based on XML and HTTP"
SRC_URI="mirror://gentoo/${PN}/${P}.tar.bz2"
HOMEPAGE="http://xmlrpc-c.sourceforge.net/"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="+curl +cxx"
LICENSE="BSD"
SLOT="0"

DEPEND="dev-libs/libxml2
	curl? ( net-misc/curl )"

pkg_setup() {
	if ! use curl
	then
		ewarn "Curl support disabled: No client library will be be built"
	fi
}

#FAIL
RESTRICT="test"

PATCHES=( "${FILESDIR}/${P}-no-undefined.patch"
	"${FILESDIR}/${P}-parallel-make.patch" )

src_unpack() {
	base_src_unpack
	cd "${S}"
	# Respect the user's CFLAGS/CXXFLAGS.
	sed -i \
		-e "/CFLAGS_COMMON/s:-g -O3$:${CFLAGS}:" \
		-e "/CXXFLAGS_COMMON/s:-g$:${CXXFLAGS}:" \
		"${S}"/common.mk || die "404. File not found while sedding"

	# solaris req. c99
	if [[ ${CHOST} == *-solaris* ]] ; then
		sed -i \
			-e "/^CFLAGS_COMMON/s/= /= -std=c99 /" \
			"${S}"/common.mk || die "404. File not found while sedding"
	fi

	sed -i \
		-e "/^LIBINST_DIR = / s:\$(PREFIX)/lib:\$(PREFIX)/$(get_libdir):" \
		config.mk.in
}

src_compile() {
	#Bug 214137: We need to filter this.
	unset SRCDIR

	# Respect the user's LDFLAGS.
	export LADD=${LDFLAGS}
	export CFLAGS_PERSONAL="${CFLAGS}"
	econf	--disable-wininet-client \
		--enable-libxml2-backend \
		--disable-libwww-client \
		--disable-abyss-server \
		--enable-cgi-server \
		--disable-abyss-threads \
		$(use_enable cxx cplusplus) \
		$(use_enable curl curl-client) \
		|| die "econf failed"
	emake || die "emake failed"
}

src_test() {
	unset LDFLAGS LADD SRCDIR
	cd "${S}"/src/test/
	einfo "Building general tests"
	make || die "Make of general tests failed"
	einfo "Running general tests"
	./test || die "General tests failed"

	cd "${S}"/src/cpp/test
	einfo "Building C++ tests"
	make || die "Make of C++ tests failed"
	einfo "Running C++ tests"
	./test || die "C++ tests failed"
}

src_install() {
	unset SRCDIR
	emake DESTDIR="${D}" install || die "installation failed"

	dodoc README doc/CREDITS doc/DEVELOPING doc/HISTORY doc/SECURITY doc/TESTING \
		doc/TODO || die "installing docs failed"
}
