# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/icu/icu-51.1.ebuild,v 1.2 2013/04/06 18:40:29 blueness Exp $

EAPI=5

inherit eutils toolchain-funcs base autotools

DESCRIPTION="International Components for Unicode"
HOMEPAGE="http://www.icu-project.org/"
SRC_URI="http://download.icu-project.org/files/icu4c/${PV/_/}/icu4c-${PV//./_}-src.tgz"

LICENSE="BSD"
SLOT="0/51.1"
KEYWORDS="~ppc-aix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="debug doc examples static-libs"

DEPEND="
	doc? (
		app-doc/doxygen[dot]
	)
"

S="${WORKDIR}/${PN}/source"

PATCHES=(
	"${FILESDIR}/${PN}-4.8.1-fix_binformat_fonts.patch"
	"${FILESDIR}/${PN}-4.8.1.1-fix_ltr.patch"
)

src_prepare() {
	local variable

	base_src_prepare

	# Do not hardcode flags in icu-config and icu-*.pc files.
	# https://ssl.icu-project.org/trac/ticket/6102
	for variable in CFLAGS CPPFLAGS CXXFLAGS FFLAGS LDFLAGS; do
		sed \
			-e "/^${variable} =.*/s: *@${variable}@\( *$\)\?::" \
			-i config/icu.pc.in \
			-i config/Makefile.inc.in \
			|| die
	done

	# fix compilation on Solaris due to enabling of conflicting standards
	sed -i -e '/define _XOPEN_SOURCE_EXTENDED/s/_XOPEN/no_XOPEN/' \
		common/uposixdefs.h || die
	# for correct install_names
	epatch "${FILESDIR}"/${PN}-4.8.1-darwin.patch
	# fix part 1 for echo_{t,c,n}
	epatch "${FILESDIR}"/${PN}-4.6-echo_t.patch

	# Disable renaming as it is stupind thing to do
	sed -i \
		-e "s/#define U_DISABLE_RENAMING 0/#define U_DISABLE_RENAMING 1/" \
		common/unicode/uconfig.h || die

	# Fix linking of icudata
	sed -i \
		-e "s:LDFLAGSICUDT=-nodefaultlibs -nostdlib:LDFLAGSICUDT=:" \
		config/mh-linux || die

	# Append doxygen configuration to configure
	sed -i \
		-e 's:icudefs.mk:icudefs.mk Doxyfile:' \
		configure.in || die
	eautoreconf
}

src_configure() {
	local cross_opts

	# bootstrap for cross compilation
	if tc-is-cross-compiler; then
		CFLAGS="" CXXFLAGS="" ASFLAGS="" LDFLAGS="" \
		CC="$(tc-getBUILD_CC)" CXX="$(tc-getBUILD_CXX)" AR="$(tc-getBUILD_AR)" \
		RANLIB="$(tc-getBUILD_RANLIB)" LD="$(tc-getBUILD_LD)" \
		./configure --disable-renaming --disable-debug \
			--disable-samples --enable-static || die
		emake
		mkdir -p "${WORKDIR}/host/"
		cp -a {bin,lib,config,tools} "${WORKDIR}/host/"
		emake clean

		cross_opts="--with-cross-build=${WORKDIR}/host"
	fi

	# make sure we configure with the same shell as we run icu-config
	# with, or ECHO_N, ECHO_T and ECHO_C will be wrongly defined
	# (this is part 2 from the echo_{t,c,n} fix)
	export CONFIG_SHELL=${CONFIG_SHELL:-${EPREFIX}/bin/sh}
	econf \
		--disable-renaming \
		$(use_enable debug) \
		$(use_enable examples samples) \
		$(use_enable static-libs static) \
		${cross_opts}
}

src_compile() {
	default

	if use doc; then
		doxygen -u Doxyfile || die
		doxygen Doxyfile || die
	fi
}

src_test() {
	# INTLTEST_OPTS: intltest options
	#   -e: Exhaustive testing
	#   -l: Reporting of memory leaks
	#   -v: Increased verbosity
	# IOTEST_OPTS: iotest options
	#   -e: Exhaustive testing
	#   -v: Increased verbosity
	# CINTLTST_OPTS: cintltst options
	#   -e: Exhaustive testing
	#   -v: Increased verbosity
	emake -j1 VERBOSE="1" check
}

src_install() {
	default

	dohtml ../readme.html

	use doc && dohtml -p api -r doc/html/
}
