# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/icu/icu-50_rc.ebuild,v 1.1 2012/10/25 18:53:59 floppym Exp $

EAPI="5"

inherit eutils versionator

MAJOR_VERSION="$(get_version_component_range 1)"
if [[ "${PV}" =~ ^[[:digit:]]+_rc[[:digit:]]*$ ]]; then
	MINOR_VERSION="1"
else
	MINOR_VERSION="$(get_version_component_range 2)"
fi

DESCRIPTION="International Components for Unicode"
HOMEPAGE="http://www.icu-project.org/"

BASE_URI="http://download.icu-project.org/files/icu4c/${PV/_/}"
SRC_ARCHIVE="icu4c-${PV//./_}-src.tgz"
DOCS_ARCHIVE="icu4c-${PV//./_}-docs.zip"

SRC_URI="${BASE_URI}/${SRC_ARCHIVE}
	doc? ( ${BASE_URI}/${DOCS_ARCHIVE} )"

LICENSE="BSD"
SLOT="0/50"
KEYWORDS="~ppc-aix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="debug doc examples static-libs"

DEPEND="doc? ( app-arch/unzip )"
RDEPEND=""

S="${WORKDIR}/${PN}/source"

QA_DT_NEEDED="/usr/lib.*/libicudata\.so\.${MAJOR_VERSION}\.${MINOR_VERSION}.*"
QA_FLAGS_IGNORED="/usr/lib.*/libicudata\.so\.${MAJOR_VERSION}\.${MINOR_VERSION}.*"

src_unpack() {
	unpack "${SRC_ARCHIVE}"
	if use doc; then
		mkdir docs
		pushd docs > /dev/null
		unpack "${DOCS_ARCHIVE}"
		popd > /dev/null
	fi
}

src_prepare() {
	# Do not hardcode flags into icu-config.
	# https://ssl.icu-project.org/trac/ticket/6102
	local variable
	for variable in CFLAGS CPPFLAGS CXXFLAGS FFLAGS LDFLAGS; do
		sed -i -e "/^${variable} =.*/s:@${variable}@::" config/Makefile.inc.in || die "sed failed"
	done

	sed -e "s/#define U_DISABLE_RENAMING 0/#define U_DISABLE_RENAMING 1/" -i common/unicode/uconfig.h

	# fix compilation on Solaris due to enabling of conflicting standards
	sed -i -e '/define _XOPEN_SOURCE_EXTENDED/s/_XOPEN/no_XOPEN/' \
		common/uposixdefs.h || die
	# for correct install_names
	epatch "${FILESDIR}"/${PN}-4.8.1-darwin.patch
	# fix part 1 for echo_{t,c,n}
	epatch "${FILESDIR}"/${PN}-4.6-echo_t.patch

	epatch "${FILESDIR}/${PN}-4.8.1-fix_binformat_fonts.patch"
	epatch "${FILESDIR}/${PN}-4.8.1.1-fix_ltr.patch"
	epatch "${FILESDIR}/${P}-platforms.patch"
}

src_configure() {
	# make sure we configure with the same shell as we run icu-config
	# with, or ECHO_N, ECHO_T and ECHO_C will be wrongly defined
	# (this is part 2 from the echo_{t,c,n} fix)
	export CONFIG_SHELL=${CONFIG_SHELL:-${EPREFIX}/bin/sh}
	# http://bugs.icu-project.org/trac/ticket/8551: --disable-strict
	econf \
		--disable-renaming \
		--disable-strict \
		$(use_enable debug) \
		$(use_enable examples samples) \
		$(use_enable static-libs static)
}

src_compile() {
	# Darwin/x86 needs an object index
	emake VERBOSE="1" ARFLAGS="sr"
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
	emake DESTDIR="${D}" VERBOSE="1" install

	dohtml ../readme.html
	dodoc ../unicode-license.txt
	if use doc; then
		insinto /usr/share/doc/${PF}/html/api
		doins -r "${WORKDIR}/docs/"*
	fi
}
