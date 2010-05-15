# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/icu/icu-4.4.1.ebuild,v 1.1 2010/04/29 18:22:54 arfrever Exp $

EAPI="3"

inherit flag-o-matic versionator

MAJOR_MINOR_VERSION="$(get_version_component_range 1-2)"

DESCRIPTION="International Components for Unicode"
HOMEPAGE="http://www.icu-project.org/"

BASE_URI="http://download.icu-project.org/files/icu4c/${PV}"
DOCS_BASE_URI="http://download.icu-project.org/files/icu4c/${MAJOR_MINOR_VERSION}"
SRC_ARCHIVE="icu4c-${PV//./_}-src.tgz"
DOCS_ARCHIVE="icu4c-${MAJOR_MINOR_VERSION//./_}-docs.zip"

SRC_URI="${BASE_URI}/${SRC_ARCHIVE}
	doc? ( ${DOCS_BASE_URI}/${DOCS_ARCHIVE} )"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~ppc-aix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="debug doc examples"

DEPEND="doc? ( app-arch/unzip )"
RDEPEND=""

S="${WORKDIR}/${PN}/source"

QA_DT_NEEDED="/usr/lib.*/libicudata.so.${MAJOR_MINOR_VERSION/./}.0"

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
	# Do not hardcode used CFLAGS, LDFLAGS etc. into icu-config
	# Bug 202059
	# https://bugs.icu-project.org/trac/ticket/6102
	for x in ARFLAGS CFLAGS CPPFLAGS CXXFLAGS FFLAGS LDFLAGS; do
		sed -i -e "/^${x} =.*/s:@${x}@::" "config/Makefile.inc.in" || die "sed failed"
	done

	# for correct install_names
	epatch "${FILESDIR}"/${PN}-3.8.1-darwin.patch
}

src_configure() {
	if [[ ${CHOST} == *-irix* ]]; then
		if [[ -n "${LD_LIBRARYN32_PATH}" || -n "${LD_LIBRARY64_PATH}" ]]; then
			case "${ABI:-$DEFAULT_ABI}" in
				mips32)
					if [[ -z "${LD_LIBRARY_PATH}" ]]; then
						LD_LIBRARY_PATH="${LD_LIBRARYN32_PATH}"
					else
						LD_LIBRARY_PATH="${LD_LIBRARYN32_PATH}:${LD_LIBRARY_PATH}"
					fi
					;;
				mips64)
					if [[ -z "${LD_LIBRARY_PATH}" ]]; then
						LD_LIBRARY_PATH="${LD_LIBRARY64_PATH}"
					else
						LD_LIBRARY_PATH="${LD_LIBRARY64_PATH}:${LD_LIBRARY_PATH}"
					fi
					;;
				mipso32|*)
					:
					;;
			esac
		fi
		export LD_LIBRARY_PATH
		unset  LD_LIBRARYN32_PATH
		unset  LD_LIBRARY64_PATH
	fi

	econf \
		--enable-static \
		$(use_enable debug) \
		$(use_enable examples samples)
}

src_compile() {
	# Darwin needs an object index
	emake ARFLAGS="sr" || die
}

src_test() {
	emake check || die "emake check failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dohtml ../readme.html
	dodoc ../unicode-license.txt
	if use doc; then
		insinto /usr/share/doc/${PF}/html/api
		doins -r "${WORKDIR}/docs/"*
	fi
}
