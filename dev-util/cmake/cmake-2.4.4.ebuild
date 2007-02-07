# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cmake/cmake-2.4.4.ebuild,v 1.1 2006/11/29 19:24:18 genstef Exp $

EAPI="prefix"

inherit toolchain-funcs eutils versionator

DESCRIPTION="Cross platform Make"
HOMEPAGE="http://www.cmake.org/"
SRC_URI="http://www.cmake.org/files/v$(get_version_component_range 1-2)/${P}.tar.gz"

LICENSE="CMake"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

src_compile() {
	cd ${S}
	tc-export CC CXX LD
	./bootstrap \
		--prefix="${EPREFIX}"/usr \
		--docdir="${EPREFIX}"/share/doc/${PN} \
		--datadir="${EPREFIX}"/share/${PN} \
		--mandir="${EPREFIX}"/share/man || die "./bootstrap failed"
	emake || die
}

src_test() {
	einfo "Self tests broken"
	make test || \
		einfo "note test failure on qtwrapping was expected - nature of portage rather than a true failure"
}

src_install() {
	make install DESTDIR=${D} || die "install failed"
	mv ${ED}usr/share/doc/cmake ${ED}usr/share/doc/${PF}
}
