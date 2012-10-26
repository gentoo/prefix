# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/pax-utils/pax-utils-0.4.ebuild,v 1.8 2012/07/10 18:05:58 ranger Exp $

inherit eutils toolchain-funcs unpacker flag-o-matic

DESCRIPTION="ELF related utils for ELF 32/64 binaries that can check files for security relevant properties"
HOMEPAGE="http://hardened.gentoo.org/pax-utils.xml"
SRC_URI="mirror://gentoo/pax-utils-${PV}.tar.xz
	http://dev.gentoo.org/~solar/pax/pax-utils-${PV}.tar.xz
	http://dev.gentoo.org/~vapier/dist/pax-utils-${PV}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~ia64-hpux ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="caps"
#RESTRICT="mirror"

RDEPEND="caps? ( sys-libs/libcap )
	ia64-hpux? ( dev-libs/gnulib )"
DEPEND="${RDEPEND}
	app-arch/xz-utils"

src_compile() {
	local libs
	if [[ ${CHOST} == *-hpux* ]]; then
		append-flags -I"${EPREFIX}"/usr/$(get_libdir)/gnulib/include
		append-ldflags -L"${EPREFIX}"/usr/$(get_libdir)/gnulib/lib
		libs="-lgnu"
	fi
	emake CC="$(tc-getCC)" LIBS="${libs}" USE_CAP=$(usex caps) || die
}

src_install() {
	emake DESTDIR="${D}${EPREFIX}" PKGDOCDIR='$(DOCDIR)'/${PF} install || die
	prepalldocs
}
