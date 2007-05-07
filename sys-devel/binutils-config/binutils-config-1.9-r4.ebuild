# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils-config/binutils-config-1.9-r4.ebuild,v 1.1 2007/05/06 09:04:01 vapier Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="Utility to change the binutils version being used - prefix version"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-aix ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE=""

RDEPEND=">=sys-apps/findutils-4.2"

W_VER=1.2

src_unpack() {
	cp "${FILESDIR}"/${PN}-${PV} "${T}"/
	cp "${FILESDIR}"/ldwrapper-${W_VER}.c "${T}"/
	eprefixify "${T}"/${PN}-${PV} "${T}"/ldwrapper-${W_VER}.c
}

src_compile() {
	cd "${T}"

	# based on what system we have do some adjusting of the wrapper's work
	case ${CHOST} in
		*-darwin*)
			defines='-DNEEDS_LIBRARY_INCLUDES -DLIBINC="-L"'
			defines="${defines}"' -DNEEDS_EXTRAS -DEXTRA="-search_paths_first"'
		;;
		*-aix*)
			defines='-DNEEDS_LIBRARY_INCLUDES -DLIBINC="-L"'
		;;
		*-solaris*)
			defines='-DNEEDS_LIBRARY_INCLUDES -DLIBINC="-L"'
			defines="${defines}"' -DNEEDS_RPATH_DIRECTIONS -DRPATHDIR="-R"'
		;;
		*-linux-gnu)
			defines='-DNEEDS_LIBRARY_INCLUDES -DLIBINC="-L"'
			defines="${defines}"' -DNEEDS_RPATH_DIRECTIONS -DRPATHDIR="-rpath="'
		;;
		*)
			die "Don't know how to configure for your system"
		;;
	esac

	echo "$(tc-getCC) -O2 -Wall ${defines} -o ldwrapper \
		ldwrapper-${W_VER}.c"
	$(tc-getCC) -O2 -Wall ${defines} -o ldwrapper \
		ldwrapper-${W_VER}.c || die "compile wrapper"
}

src_install() {
	newbin "${T}"/${PN}-${PV} ${PN} || die
	doman "${FILESDIR}"/${PN}.8

	exeinto /usr/$(get_libdir)/misc
	newexe "${T}"/ldwrapper binutils-config || die "install ldwrapper"
}

pkg_postinst() {
	# refresh all links and the wrapper
	if [[ ${ROOT%/} == "" ]] ; then
		[[ -f ${EROOT}/etc/env.d/binutils/config-${CHOST} ]] \
			&& binutils-config $(${EROOT}/usr/bin/binutils-config --get-current-profile)
	fi
}
