# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/boost-build/boost-build-1.35.0-r1.ebuild,v 1.11 2010/08/14 06:35:54 dirtyepic Exp $

inherit flag-o-matic toolchain-funcs versionator

MY_PV=$(replace_all_version_separators _)

DESCRIPTION="A system for large project software construction, which is simple to use and powerful."
HOMEPAGE="http://www.boost.org/doc/tools/build/index.html"
SRC_URI="mirror://sourceforge/boost/boost_${MY_PV}.tar.bz2"
LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="examples python"

DEPEND="!<dev-libs/boost-1.34.0
	python? ( dev-lang/python )"
RDEPEND="${DEPEND}"

S=${WORKDIR}/boost_${MY_PV}/tools

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PV}-fix_broken_icu_build.patch"

	epatch "${FILESDIR}"/${PV}-darwin-sanitise.patch

	# adds support for boosting with parity ...
	epatch "${FILESDIR}"/${PV}-winnt.patch

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
		-e 's/\(off speed space\)/\1 none/' \
		-e 's/\(debug-symbols      : on off\)/\1 none/' \
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

	# The build.jam file for building bjam using a bootstrapped jam0 ignores
	# the LDFLAGS env var (bug #209794). We have now two options:
	# a) change the cc-target definition in build.jam to include separate compile
	#    and link targets to make it use the LDFLAGS var, or
	# b) a simple dirty workaround by injecting the LDFLAGS in the LIBS env var
	#    (which should not be set by us).
	if [[ -z "${LDFLAGS}" ]] ; then
		CC=$(tc-getCC) ./build.sh ${toolset} $(use_with python) \
			|| die "building bjam failed"
	else
		LDFLAGS=$(echo ${LDFLAGS}) # 293652
		LIBS=${LDFLAGS} CC=$(tc-getCC) ./build.sh ${toolset} \
			$(use_with python) || die "building bjam failed"
	fi
}

src_install() {
	dobin jam/src/bin.*/bjam

	cd "${S}/build/v2"
	insinto /usr/share/boost-build
	doins -r boost-build.jam bootstrap.jam build-system.jam site-config.jam user-config.jam \
		build kernel options tools util || die

	dodoc doc/userman.pdf changes.txt hacking.txt release_procedure.txt \
		notes/build_dir_option.txt notes/relative_source_paths.txt

	if use examples ; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}

src_test() {
	cd jam/test
	./test.sh || die "tests failed"
}
