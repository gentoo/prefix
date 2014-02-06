# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/pax-utils/pax-utils-0.7.ebuild,v 1.10 2014/01/18 03:18:03 vapier Exp $

EAPI=4

inherit eutils toolchain-funcs unpacker flag-o-matic

DESCRIPTION="ELF related utils for ELF 32/64 binaries that can check files for security relevant properties"
HOMEPAGE="http://hardened.gentoo.org/pax-utils.xml"
SRC_URI="mirror://gentoo/pax-utils-${PV}.tar.xz
	http://dev.gentoo.org/~solar/pax/pax-utils-${PV}.tar.xz
	http://dev.gentoo.org/~vapier/dist/pax-utils-${PV}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~ia64-hpux ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="caps python"
#RESTRICT="mirror"

RDEPEND="caps? ( sys-libs/libcap )
	python? ( dev-python/pyelftools )
	ia64-hpux? ( dev-libs/gnulib )"
DEPEND="${RDEPEND}
	app-arch/xz-utils"

_emake() {
	emake \
		USE_CAP=$(usex caps) \
		USE_PYTHON=$(usex python) \
		"$@"
}

src_compile() {
	local libs
	if [[ ${CHOST} == *-hpux* ]]; then
		append-flags -I"${EPREFIX}"/usr/$(get_libdir)/gnulib/include
		append-ldflags -L"${EPREFIX}"/usr/$(get_libdir)/gnulib/lib
		libs="-lgnu"
	fi
	_emake CC="$(tc-getCC)" LIBS="${libs}"
}

src_test() {
	_emake check
}

src_install() {
	_emake CC="$(tc-getCC)" DESTDIR="${D}${EPREFIX}" PKGDOCDIR='$(DOCDIR)'/${PF} install
}
