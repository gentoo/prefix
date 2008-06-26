# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit eutils

DESCRIPTION="Host OS native assembler as and static linker ld"
HOMEPAGE="http://youroperatingsystem.com/"
SRC_URI=""

LICENSE="GPL-2" # actually, we don't know, the wrapper is
SLOT="0"

KEYWORDS="~ppc-aix ~x86-interix ~ppc-macos ~x86-macos ~x86-solaris"

IUSE=""

DEPEND="sys-devel/binutils-config"
RDEPEND="${DEPEND}"

src_install() {
	LIBPATH=/usr/$(get_libdir)/binutils/${CHOST}/native-${PV}
	BINPATH=/usr/${CHOST}/binutils-bin/native-${PV}

	keepdir ${LIBPATH} || die
	dodir ${BINPATH} || die

	# allow for future hosts with different paths
	nativepath=""
	case ${CHOST} in
		*-solaris*|*-aix*)
			nativepath=/usr/ccs/bin
		;;
		*-apple-darwin*|*-netbsd*|*-openbsd*)
			nativepath=/usr/bin
		;;
		*-interix*)
			nativepath=/opt/gcc.3.3/bin
		;;
		*)
			die "Don't know where the native linker for your platform is"
		;;
	esac

	what="addr2line as ar c++filt gprof ld nm objcopy objdump \
		ranlib readelf elfdump size strings strip"
	# Darwin things
	what="${what} install_name_tool ld64 libtool lipo nmedit \
		otool otool64 pagestuff redo_prebinding segedit"

	# copy from the host os
	cd "${ED}${BINPATH}"
	for b in ${what} ; do
		if [[ -x ${nativepath}/${b} ]] ; then
			einfo "linking ${nativepath}/${b}"
			ln -s "${nativepath}/${b}" "${b}"
		else
			ewarn "skipping ${b} (not in ${nativepath})"
		fi
	done

	# post fix for Darwin's ranlib (doesn't like it when its called other than
	# that, as libtool and ranlib are one tool)
	if [[ ${CHOST} == *-darwin* ]] ; then
		rm -f ranlib
		cat <<-EOF > ranlib
			#!/usr/bin/env bash
			exec ${nativepath}/ranlib "\$@"
		EOF
		chmod 755 ranlib
	fi

	# Generate an env.d entry for this binutils
	insinto /etc/env.d/binutils
	cat <<-EOF > "${T}"/env.d
		TARGET="${CHOST}"
		VER="native-${PV}"
		LIBPATH="${EPREFIX}/${LIBPATH}"
		FAKE_TARGETS="${CHOST}"
	EOF
	newins "${T}"/env.d ${CHOST}-native-${PV}
}

pkg_postinst() {
	binutils-config ${CHOST}-native-${PV}
}
