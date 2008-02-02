# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils-config/binutils-config-1.9-r4.ebuild,v 1.1 2007/05/06 09:04:01 vapier Exp $

EAPI="prefix"

inherit eutils toolchain-funcs flag-o-matic

DESCRIPTION="Utility to change the binutils version being used - prefix version"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""
EXTW_VER="0.1.0.1593"
SRC_URI="extwrapper? ( http://dev.gentoo.org/~haubi/distfiles/toolchain-prefix-wrapper-${EXTW_VER}.tar.bz2 )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-fbsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="extwrapper"

RDEPEND=">=sys-apps/findutils-4.2
	>=sys-devel/gcc-config-1.4.0"

W_VER=1.3

S="${WORKDIR}/toolchain-prefix-wrapper-${EXTW_VER}"

pkg_setup() {
	if ! use extwrapper; then
		[[ ${CTARGET} == *-hpux* ]] && die "Please USE 'extwrapper' on ${CTARGET}"
	fi
}

localwrapper_src_unpack() {
	cp "${FILESDIR}"/${PN}-${PV}-old "${T}"/${PN}-${PV}
	cp "${FILESDIR}"/ldwrapper-${W_VER}.c "${T}"/
	eprefixify "${T}"/${PN}-${PV} "${T}"/ldwrapper-${W_VER}.c
	# YES, this binutils-config is NOT cross-compile safe
	sed -i -e "s:@CHOST@:${CHOST}:" "${T}"/ldwrapper-${W_VER}.c
}

extwrapper_src_unpack() {
	unpack ${A}
	cp "${FILESDIR}"/${PN}-${PV}-old "${T}"/${PN}-${PV}
	eprefixify "${T}"/${PN}-${PV}
}

src_unpack() {
	if use extwrapper; then
		extwrapper_src_unpack
	else
		localwrapper_src_unpack
	fi
}

localwrapper_src_compile() {
	cd "${T}"

	# based on what system we have do some adjusting of the wrapper's work
	case ${CHOST} in
		*-darwin*)
			defines='-DNEEDS_LIBRARY_INCLUDES -DLIBINC=\"-L\"'
			defines="${defines}"' -DNEEDS_EXTRAS "-DEXTRA=\"-search_paths_first -macosx_version_min '"${MACOSX_DEPLOYMENT_TARGET}"'\""'
		;;
		*-aix*)
			defines='-DNEEDS_LIBRARY_INCLUDES -DLIBINC=\"-L\"'
		;;
		*-solaris*)
			defines='-DNEEDS_LIBRARY_INCLUDES -DLIBINC=\"-L\"'
			defines="${defines}"' -DNEEDS_RPATH_DIRECTIONS -DRPATHDIR=\"-R\"'
		;;
		*-linux-gnu|*-freebsd*|*-netbsd*)
			defines='-DNEEDS_LIBRARY_INCLUDES -DLIBINC=\"-L\"'
			defines="${defines}"' -DNEEDS_RPATH_DIRECTIONS -DRPATHDIR=\"-rpath=\"'
		;;
		*)
			die "Don't know how to configure for your system"
		;;
	esac

	echo "$(tc-getCC) -O2 -Wall ${defines} -o ldwrapper ldwrapper-${W_VER}.c"
	eval "$(tc-getCC) -O2 -Wall ${defines} -o ldwrapper ldwrapper-${W_VER}.c" \
		|| die "compile wrapper"
}

extwrapper_src_compile() {
	[[ ${CHOST} == *-interix* ]] && append-flags "-D_ALL_SOURCE"

	econf --bindir="${EPREFIX}"/usr/lib/misc
	emake || die "emake failed."
}

src_compile() {
	if use extwrapper; then
		extwrapper_src_compile
	else
		localwrapper_src_compile
	fi
}

localwrapper_src_install() {
	newbin "${T}"/${PN}-${PV} ${PN} || die
	doman "${FILESDIR}"/${PN}.8

	exeinto /usr/$(get_libdir)/misc
	newexe "${T}"/ldwrapper binutils-config || die "install ldwrapper"
}

extwrapper_src_install() {
	emake install DESTDIR="${D}" || die "emake install failed."
	mv "${ED}"/usr/$(get_libdir)/misc/{prefixld,binutils-config} \
	|| die "Cannot rename prefixld to binutils-config"

	newbin "${T}"/${PN}-${PV} ${PN} || die
	doman "${FILESDIR}"/${PN}.8
}

src_install() {
	if use extwrapper; then
		extwrapper_src_install
	else
		localwrapper_src_install
	fi
}

pkg_postinst() {
	# refresh all links and the wrapper
	if [[ ${ROOT%/} == "" ]] ; then
		[[ -f ${EROOT}/etc/env.d/binutils/config-${CHOST} ]] \
			&& binutils-config $(${EROOT}/usr/bin/binutils-config --get-current-profile)
	fi
}
