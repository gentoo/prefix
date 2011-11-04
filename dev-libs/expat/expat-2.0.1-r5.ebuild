# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/expat/expat-2.0.1-r5.ebuild,v 1.7 2011/10/23 12:55:47 armin76 Exp $

EAPI=4
inherit eutils libtool toolchain-funcs autotools

DESCRIPTION="XML parsing libraries"
HOMEPAGE="http://expat.sourceforge.net/"
SRC_URI="mirror://sourceforge/expat/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="elibc_FreeBSD examples static-libs"

src_prepare() {
	epatch \
		"${FILESDIR}"/${P}-check_stopped_parser.patch \
		"${FILESDIR}"/${P}-fix_bug_1990430.patch \
		"${FILESDIR}"/${P}-CVE-2009-3560-revised.patch

	# this eautoreconf is required _at least_ by all interix and winnt
	# platforms to add shared library support
	# it breaks during bootstrap, however, so only run on interix and winnt
	if [[ ${CHOST} == *-interix* || ${CHOST} == *-winnt* ]] ; then
		local mylt=$(type -P libtoolize)
		cp "${mylt%/bin/libtoolize}"/share/aclocal/libtool.m4 conftools/libtool.m4
		AT_M4DIR="conftools" eautoreconf
	fi

	epunt_cxx

	mkdir "${S}"-build{,u,w} || die
}

src_configure() {
	local myconf="$(use_enable static-libs static)"

	local d
	for d in build buildu buildw; do
		pushd "${S}"-${d}
		[[ ${d} == buildu ]] && export GENTOO_CPPFLAGS="-UXML_UNICODE"
		[[ ${d} == buildw ]] && export GENTOO_CPPFLAGS="-UXML_UNICODE -DXML_UNICODE_WCHAR_T"
		CPPFLAGS="${CPPFLAGS} ${GENTOO_CPPFLAGS}" ECONF_SOURCE="${S}" econf ${myconf}
		popd
	done
}

src_compile() {
	cd "${S}"-build
	emake
	cd "${S}"-buildu
	emake buildlib LIBRARY=libexpatu.la
	cd "${S}"-buildw
	emake buildlib LIBRARY=libexpatw.la
}

src_install() {
	dodoc Changes README
	dohtml doc/*

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins examples/*.c
	fi

	cd "${S}"-build
	emake install DESTDIR="${D}"
	cd "${S}"-buildu
	emake installlib DESTDIR="${D}" LIBRARY=libexpatu.la
	cd "${S}"-buildw
	emake installlib DESTDIR="${D}" LIBRARY=libexpatw.la

	use static-libs || rm -f "${ED}"usr/lib*/libexpat{,u,w}.la

	# libgeom in /lib and ifconfig in /sbin require it on FreeBSD since we
	# stripped the libbsdxml copy starting from freebsd-lib-8.2-r1
	use elibc_FreeBSD && gen_usr_ldscript -a expat{,u,w}
}
