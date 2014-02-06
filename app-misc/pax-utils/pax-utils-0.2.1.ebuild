# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/pax-utils/pax-utils-0.2.1.ebuild,v 1.8 2012/02/07 16:58:10 vapier Exp $

inherit toolchain-funcs flag-o-matic

DESCRIPTION="ELF related utils for ELF 32/64 binaries that can check files for security relevant properties"
HOMEPAGE="http://hardened.gentoo.org/pax-utils.xml"
SRC_URI="mirror://gentoo/pax-utils-${PV}.tar.bz2
	http://dev.gentoo.org/~solar/pax/pax-utils-${PV}.tar.bz2
	http://dev.gentoo.org/~vapier/dist/pax-utils-${PV}.tar.bz2"
#SRC_URI="http://wh0rd.org/pax-utils-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~ia64-hpux ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="caps"
#RESTRICT="mirror"

DEPEND="caps? ( sys-libs/libcap )
	ia64-hpux? ( dev-libs/gnulib )
"

src_compile() {
	local libs
	if [[ ${CHOST} == *-hpux* ]]; then
		append-flags -I"${EPREFIX}"/usr/$(get_libdir)/gnulib/include
		append-ldflags -L"${EPREFIX}"/usr/$(get_libdir)/gnulib/lib
		libs="-lgnu"
	fi
	# we use C99 features but don't adhere to C99 specs, so ...
	append-flags -std=gnu99
	emake CC="$(tc-getCC)" LIBS="${libs}" USE_CAP=$(use caps && echo yes) || die
}

src_install() {
	emake CC="$(tc-getCC)" DESTDIR="${D}${EPREFIX}" install || die
	dodoc BUGS README TODO
}
