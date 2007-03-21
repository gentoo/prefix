# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit eutils

DESCRIPTION="Host OS native assembler as and static linker ld"
HOMEPAGE="http://youroperatingsystem.com/"
SRC_URI=""

LICENSE="GPL-2" # actually, we don't know
SLOT="0"

KEYWORDS="~ppc-aix ~x86-solaris"

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
		*)
			die "Don't know where the native linker for your platform is"
		;;
	esac

	what="addr2line as ar c++filt gprof ld nm objcopy objdump \
		ranlib readelf elfdump size strings strip"

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

	# Generate an env.d entry for this binutils
	insinto /etc/env.d/binutils
	cat <<-EOF > env.d
		TARGET="${CHOST}"
		VER="native-${PV}"
		LIBPATH="${EPREFIX}/${LIBPATH}"
		FAKE_TARGETS="${CHOST}"
	EOF
	# indicate we're dealing with a native (non-prefix) linker here, by
	# replacing the machine (2nd) tuple in the CHOST by "native"
	FCHOST=${CHOST/-*-/-native-}
	newins env.d ${FCHOST}-${PV}
}

pkg_postinst() {
	binutils-config ${FCHOST}-${PV}
}
