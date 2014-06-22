# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/expat/expat-2.1.0-r3.ebuild,v 1.15 2014/04/28 17:27:28 mgorny Exp $

EAPI=5
inherit eutils libtool multilib toolchain-funcs autotools flag-o-matic multilib-minimal

DESCRIPTION="XML parsing libraries"
HOMEPAGE="http://expat.sourceforge.net/"
SRC_URI="mirror://sourceforge/expat/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="elibc_FreeBSD examples static-libs unicode"
RDEPEND="abi_x86_32? ( !<=app-emulation/emul-linux-x86-baselibs-20130224-r6
		!app-emulation/emul-linux-x86-baselibs[-abi_x86_32(-)] )"

src_prepare() {
	# this eautoreconf is required _at least_ by all interix and winnt
	# platforms to add shared library support
	# it breaks during bootstrap, however, so only run on interix and winnt
	if [[ ${CHOST} == *-interix* || ${CHOST} == *-winnt* ]] ; then
		local mylt=$(type -P libtoolize)
		cp "${mylt%/bin/libtoolize}"/share/aclocal/libtool.m4 conftools/libtool.m4
		AT_M4DIR="conftools" eautoreconf
	else
		elibtoolize
	fi

}

multilib_src_configure() {
	# compilation with -O0 fails on solaris 11.
	if [[ ${CHOST} == *-solaris* ]] ; then
		replace-flags -O0 -O2
		is-flagq -O[s123] || append-flags -O2
	fi

	local myconf="$(use_enable static-libs static)"

	mkdir -p "${BUILD_DIR}"{u,w} || die

	ECONF_SOURCE="${S}" econf ${myconf}

	if use unicode; then
		pushd "${BUILD_DIR}"u >/dev/null
		CPPFLAGS="${CPPFLAGS} -DXML_UNICODE" ECONF_SOURCE="${S}" econf ${myconf}
		popd >/dev/null

		pushd "${BUILD_DIR}"w >/dev/null
		CPPFLAGS="${CPPFLAGS} -DXML_UNICODE_WCHAR_T" ECONF_SOURCE="${S}" econf ${myconf}
		popd >/dev/null
	fi
}

multilib_src_compile() {
	emake

	if use unicode; then
		pushd "${BUILD_DIR}"u >/dev/null
		emake buildlib LIBRARY=libexpatu.la
		popd >/dev/null

		pushd "${BUILD_DIR}"w >/dev/null
		emake buildlib LIBRARY=libexpatw.la
		popd >/dev/null
	fi
}

multilib_src_install() {
	emake install DESTDIR="${D}"

	if use unicode; then
		pushd "${BUILD_DIR}"u >/dev/null
		emake installlib DESTDIR="${D}" LIBRARY=libexpatu.la
		popd >/dev/null

		pushd "${BUILD_DIR}"w >/dev/null
		emake installlib DESTDIR="${D}" LIBRARY=libexpatw.la
		popd >/dev/null

		pushd "${ED}"/usr/$(get_libdir)/pkgconfig >/dev/null
		cp expat.pc expatu.pc
		sed -i -e '/^Libs/s:-lexpat:&u:' expatu.pc || die
		cp expat.pc expatw.pc
		sed -i -e '/^Libs/s:-lexpat:&w:' expatw.pc || die
		popd >/dev/null
	fi

	if multilib_is_native_abi ; then
		# libgeom in /lib and ifconfig in /sbin require libexpat on FreeBSD since
		# we stripped the libbsdxml copy starting from freebsd-lib-8.2-r1
		use elibc_FreeBSD && gen_usr_ldscript -a expat
	fi
}

multilib_src_install_all() {
	dodoc Changes README
	dohtml doc/*

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins examples/*.c
	fi

	prune_libtool_files
}
