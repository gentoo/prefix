# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/duma/duma-2.5.15.ebuild,v 1.1 2009/08/01 20:00:23 nerdboy Exp $

EAPI=2
inherit eutils flag-o-matic multilib toolchain-funcs versionator prefix

MY_P=${PN}_$(replace_all_version_separators '_')

DESCRIPTION="DUMA (Detect Unintended Memory Access) is a memory debugging library"
HOMEPAGE="http://duma.sourceforge.net"
SRC_URI="mirror://sourceforge/duma/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="examples"

RDEPEND="app-shells/bash"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

src_prepare() {
	epatch "${FILESDIR}"/${P}-GNUmakefile.patch
	epatch "${FILESDIR}"/${PN}-2.5.13-prefix.patch
	sed -i -e "s:lib\(/libduma.dylib\):$(get_libdir)\1:" duma.sh || die
	eprefixify duma.sh
}

src_compile() {
	# strip-flags
	replace-flags O? O0
	append-flags -Wall -Wextra -U_FORTIFY_SOURCE
	tc-export AR CC CXX LD RANLIB

	case "${CHOST}" in
	    *-linux-gnu)
			OS=linux;;
	    *-solaris*)
			OS=solaris;;
	    *-darwin*)
			OS=osx;;
	    *-freebsd*)
			OS=freebsd;;
	    *-netbsd*)
			OS=netbsd;;
	    *-cygwin*)
			OS=cygwin;;
	    **-irix**)
			OS=irix;;
	esac
	export OS="${OS}"
	elog "Detected OS is: ${OS}"

	if use amd64 && ! [ -n "${DUMA_ALIGNMENT}" ]; then
		export DUMA_ALIGNMENT=16
		elog "Exported DUMA_ALIGNMENT=${DUMA_ALIGNMENT} for x86_64,"
	fi

	make reconfig || die "make config failed"
	# The above must be run first if distcc is enabled, otherwise
	# the real build breaks on parallel makes.
	emake || die "emake failed"
}

src_test() {
	emake test || die "emake test failed"

	elog "Please, see the output above to verify all tests have passed."
	elog "Both static and dynamic confidence tests should say PASSED."
}

src_install(){
	emake prefix="${ED}/usr" libdir="${ED}/usr/$(get_libdir)" \
		docdir="${ED}/usr/share/doc/${PF}" install || die "emake install failed"

	dodoc CHANGELOG TODO GNUmakefile

	if use examples; then
	    insinto /usr/share/doc/${PF}/examples
	    doins example[1-6].cpp example_makes/ex6/Makefile || die "doins failed"
	fi
}

pkg_postinst() {
	elog "See the GNUmakefile which will be also installed at"
	elog "/usr/share/doc/${PF} for more options. You can now export"
	elog "varibles to the build system easily, e.g.:"
	elog "# export CPPFLAGS=\"-DFLAG\" (or by using append-cppflags)"
	elog "# export DUMA_ALIGNMENT=${DUMA_ALIGNMENT} (Default is 16 for x86_64)"
	elog "See more information about DUMA_ALIGNMENT from Readme.txt"
}
