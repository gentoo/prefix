# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/xmlrpc-c/xmlrpc-c-1.18.02.ebuild,v 1.17 2010/12/14 03:46:30 mattst88 Exp $

EAPI=2

inherit eutils multilib base flag-o-matic

DESCRIPTION="A lightweigt RPC library based on XML and HTTP"
SRC_URI="mirror://gentoo/${PN}/${P}.tar.bz2"
HOMEPAGE="http://xmlrpc-c.sourceforge.net/"

KEYWORDS="~ppc-aix ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="+curl +cxx tools +cgi abyss threads"
LICENSE="BSD"
SLOT="0"

DEPEND="dev-libs/libxml2
	tools? ( dev-perl/frontier-rpc )
	curl? ( net-misc/curl )"
RDEPEND="${DEPEND}"

pkg_setup() {
	if ! use curl
	then
		ewarn "Curl support disabled: No client library will be be built"
	fi
}

#Bug 214137: We need to filter this.
unset SRCDIR

# Bug 255440
export LC_ALL=C
export LANG=C

PATCHES=(
	"${FILESDIR}/${P}/dumpvalue.patch"
	"${FILESDIR}/${P}/cpp-compile.patch"
	"${FILESDIR}/${P}/cpp-depends.patch"
	"${FILESDIR}/${P}/dump-symlinks.patch"
	"${FILESDIR}/${P}/libtool.patch"
	"${FILESDIR}"/${PN}-1.06.09-darwin.patch # bug #305361
	"${FILESDIR}/${P}/solaris.patch"
	"${FILESDIR}/${P}/interix.patch"
	"${FILESDIR}/${P}/have_sys_select_h.patch" # hpux11.11
	"${FILESDIR}/${P}/have_strtoll.patch" # hpux11.11, interix
	)

src_prepare() {
	base_src_prepare

	# Respect the user's CFLAGS/CXXFLAGS.
	sed -i \
		-e "/CFLAGS_COMMON/s|-g -O3$|${CFLAGS}|" \
		-e "/CXXFLAGS_COMMON/s|-g$|${CXXFLAGS}|" \
		"${S}"/common.mk || die "404. File not found while sedding"

	# solaris req. c99 (should be solved in 1.19)
	if [[ ${CHOST} == *-solaris* ]] ; then
		sed -i \
			-e "/^CFLAGS_COMMON/s/= /= -std=c99 /" \
			"${S}"/common.mk || die "404. File not found while sedding"
	fi

	# shipped shared library support is broken for aix,hpux: use libtool instead
	if [[ ${CHOST} == *-aix* || ${CHOST} == *-hpux* ]]; then
		sed -i \
			-e '/^USE_LIBTOOL/s/=/= yes/' \
			"${S}"/config.mk.in || die "404. File not found while sedding"
	fi

	# fix install_name issue
	if [[ ${CHOST} == *-darwin* ]]; then
		sed -i "s|-flat_namespace \$(SHLIB_CLIB)|\0 -install_name ${EPREFIX}/usr/$(get_libdir)/\$@|" \
		"${S}"/config.mk.in || die "patching darwin install_name failed"
	fi

}

src_configure() {
	[[ ${CHOST} == *-interix* ]] && \
		append-flags -D_REENTRANT

	# Respect the user's LDFLAGS.
	export LADD=${LDFLAGS}
	export CFLAGS_PERSONAL="${CFLAGS}"
	econf	--disable-wininet-client \
		--disable-libwww-client \
		--enable-libxml2-backend \
		$(use_enable tools) \
		$(use_enable threads abyss-threads) \
		$(use_enable cgi cgi-server) \
		$(use_enable abyss abyss-server) \
		$(use_enable cxx cplusplus) \
		$(use_enable curl curl-client)
}

src_compile() {
	emake -r || die "Compiling failed"
}

src_test() {
	if use abyss && use curl
	then
		unset LDFLAGS LADD SRCDIR
		cd "${S}"/src/test/
		einfo "Building general tests"
		make || die "Make of general tests failed"
		einfo "Running general tests"
		./test || die "General tests failed"

		if use cxx
		then
			cd "${S}"/src/cpp/test
			einfo "Building C++ tests"
			make || die "Make of C++ tests failed"
			einfo "Running C++ tests"
			./test || die "C++ tests failed"
		fi
	else
		elog "${CATEGORY}/${PN} tests will fail unless USE='abyss curl' is set."
	fi
}
