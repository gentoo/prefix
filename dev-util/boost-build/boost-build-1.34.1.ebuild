# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/boost-build/boost-build-1.34.1.ebuild,v 1.5 2008/01/24 18:59:35 opfer Exp $

EAPI="prefix"

inherit flag-o-matic toolchain-funcs versionator

MY_PV=$(replace_all_version_separators _)

DESCRIPTION="A system for large project software construction, which is simple to use and powerfull."
HOMEPAGE="http://www.boost.org/tools/build/v2/index.html"
SRC_URI="mirror://sourceforge/boost/boost_${MY_PV}.tar.bz2"

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND="!<dev-libs/boost-1.34.0"
RDEPEND=""

S=${WORKDIR}/boost_${MY_PV}/tools

src_unpack() {
	unpack ${A}

	epatch "${FILESDIR}"/${PN}-darwin.patch

	# Remove stripping option
	cd "${S}/jam/src"
	sed -i \
		-e 's/-s\b//' \
		build.jam || die "sed failed"

	# This patch allows us to fully control optimization
	# and stripping flags when bjam is used as build-system
	# We simply extend the optimization and debug-symbols feature
	# with empty dummies called 'none'
	cd "${S}/build/v2"
	sed -i \
		-e 's/\(feature optimization : off speed space\)/\1 none/' \
		-e 's/\(feature debug-symbols : on off\)/\1 none/' \
		tools/builtin.jam || die "sed failed"
}

src_compile() {
	cd jam/src
	local toolset

	if [[ ${CHOST} == *-darwin* ]] ; then
		toolset=darwin
	else
		# Using boost's generic toolset here, which respects CC and CFLAGS
		toolset=cc
	fi

	append-flags -fno-strict-aliasing

	CC=$(tc-getCC) ./build.sh ${toolset} || die "building bjam failed"
}

src_install() {
	dobin jam/src/bin.*/bjam || die

	cd "${S}/build/v2"
	insinto /usr/share/boost-build
	doins -r boost-build.jam bootstrap.jam build-system.jam site-config.jam user-config.jam \
		build kernel options tools util || die
}
