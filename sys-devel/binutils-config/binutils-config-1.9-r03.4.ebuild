# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils-config/binutils-config-1.9-r3.ebuild,v 1.1 2006/11/26 13:40:14 vapier Exp $

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

W_VER=1.1

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
			defines="-DNEEDS_LIBRARY_INCLUDES"
			libs="-search_paths_first -L${EPREFIX}/lib -L${EPREFIX}/usr/lib"
			rpaths=""
		;;
		*-aix*)
			defines="-DNEEDS_LIBRARY_INCLUDES"
			libs="-L${EPREFIX}/lib -L${EPREFIX}/usr/lib"
			rpaths=""
		;;
		*-solaris*)
			defines="-DNEEDS_LIBRARY_INCLUDES -DNEEDS_RPATH_DIRECTIONS"
			# this is a lousy check for multilib, and should be done properly
			# some day/time
			libs=""
			for dir in lib64 lib usr/lib64 usr/lib ; do
				dir=${EPREFIX}/${dir}
				[[ -d ${dir} ]] && \
					libs="${libs} -L${dir}"
			done
			rpaths=${libs//-L/-R=}
		;;
		*-linux-gnu)
			defines="-DNEEDS_LIBRARY_INCLUDES -DNEEDS_RPATH_DIRECTIONS"
			# this is a lousy check for multilib, and should be done properly
			# some day/time
			libs=""
			for dir in lib64 lib usr/lib64 usr/lib ; do
				dir=${EPREFIX}/${dir}
				[[ -d ${dir} ]] && \
					libs="${libs} -L${dir}"
			done
			rpaths=${libs//-L/-rpath=}
		;;
		*)
			die "Don't know how to configure for your system"
		;;
	esac

	sed -i \
		-e "s|@LIBRARY_INCLUDES@|${libs}|g" \
		-e "s|@RUNPATH_DIRECTIONS@|${rpaths}|g" \
		ldwrapper-${W_VER}.c

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
