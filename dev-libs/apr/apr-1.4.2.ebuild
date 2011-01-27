# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/apr/apr-1.4.2.ebuild,v 1.12 2010/09/19 09:01:59 hollow Exp $

EAPI="2"

inherit autotools eutils libtool multilib

DESCRIPTION="Apache Portable Runtime Library"
HOMEPAGE="http://apr.apache.org/"
SRC_URI="mirror://apache/apr/${P}.tar.bz2"

LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="~ppc-aix ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc older-kernels-compatibility +urandom"
RESTRICT="test"

DEPEND="doc? ( app-doc/doxygen )"
RDEPEND=""

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.2.11-mint.patch
	[[ ${CHOST} == *-irix* ]] && epatch "${FILESDIR}"/${PN}-1.3.5-irix.patch

	# Ensure that system libtool is used.
	local g=
	[[ ${CHOST} == *-darwin* ]] && g=g
	sed -e 's:${installbuilddir}/libtool:'"${EPREFIX}/usr/bin/${g}libtool"':' -i apr-config.in || die "sed failed"
	sed -e 's:@LIBTOOL@:$(SHELL) '"${EPREFIX}/usr/bin/${g}libtool"':' -i build/apr_rules.mk.in || die "sed failed"

	AT_M4DIR="build" eautoreconf
	elibtoolize

	epatch "${FILESDIR}/config.layout.patch"
}

src_configure() {
	local myconf

	[[ ${CHOST} == *-interix* ]] && export ac_cv_func_poll=no
	[[ ${CHOST} == *-mint* ]] && export ac_cv_func_poll=no

	if use older-kernels-compatibility; then
		local apr_cv_accept4 apr_cv_dup3 apr_cv_epoll_create1 apr_cv_sock_cloexec
		export apr_cv_accept4="no"
		export apr_cv_dup3="no"
		export apr_cv_epoll_create1="no"
		export apr_cv_sock_cloexec="no"
	fi

	if use urandom; then
		myconf+=" --with-devrandom=/dev/urandom"
	elif (( ${CHOST#*-hpux11.} <= 11 )); then
		: # no /dev/*random on hpux11.11 and before, $PN detects this.
	else
		myconf+=" --with-devrandom=/dev/random"
	fi

	if [[ ${CHOST} == *-mint* ]] ; then
		myconf="${myconf} --disable-dso --disable-threads"
	else
		myconf="${myconf} --enable-threads"
	fi

	# shl_load does not search runpath, but hpux11 supports dlopen
	[[ ${CHOST} == *-hpux11* ]] && myconf="${myconf} --enable-dso=dlfcn"

	if [[ ${CHOST} == *-solaris2.10 ]]; then
		case $(<$([[ ${CHOST} != ${CBUILD} ]] && echo "${EPREFIX}/usr/${CHOST}")/usr/include/atomic.h) in
		*atomic_cas_ptr*) ;;
		*)
			elog "You do not have Solaris Patch ID "$(
				[[ ${CHOST} == sparc* ]] && echo 118884 || echo 118885
			)" (Problem 4954703) installed on your host ($(hostname)),"
			elog "using generic atomic operations instead."
			myconf="${myconf} --disable-nonportable-atomics"
			;;
		esac
	fi

	CONFIG_SHELL="${EPREFIX}"/bin/bash \
	econf --enable-layout=gentoo \
		--enable-nonportable-atomics \
		${myconf}

	local g=
	[[ ${CHOST} == *-darwin* ]] && g=g

	rm -f libtool
}

src_compile() {
	emake -j1 || die "emake failed"

	if use doc; then
		emake dox || die "emake dox failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc CHANGES NOTICE README

	if use doc; then
		dohtml -r docs/dox/html/* || die "dohtml failed"
	fi

	# This file is only used on AIX systems, which Gentoo is not,
	# and causes collisions between the SLOTs, so remove it.
	rm -f "${ED}usr/$(get_libdir)/apr.exp"
}
