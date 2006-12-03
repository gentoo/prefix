# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit eutils toolchain-funcs multilib

DESCRIPTION="Baselayout and init scripts (eventually)"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/${P/-prefix/}.tar.bz2
	http://dev.gentoo.org/~uberlord/baselayout/${P/-prefix/}.tar.bz2
	http://dev.gentoo.org/~azarah/baselayout/${P/-prefix/}.tar.bz2
	http://dev.gentoo.org/~vapier/dist/${P/-prefix/}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""
DEPEND="virtual/os-headers
	>=sys-apps/portage-2.0.51"
RDEPEND=">=sys-libs/readline-5.0-r1
	>=app-shells/bash-3.1_p7
	>=sys-apps/coreutils-5.2.1"

PROVIDE="virtual/baselayout"

S=${WORKDIR}/${P/-prefix}

src_unpack() {
	unpack ${A}

	epatch "${FILESDIR}"/${P/-prefix/}-prefix.patch
	cd ${S}
	eprefixify \
		etc/env.d/00basic \
		etc/profile \
		sbin/env-update.sh \
		sbin/functions.sh
}

src_compile() {
	local libdir="lib"

	[[ ${SYMLINK_LIB} == "yes" ]] && libdir=$(get_abi_LIBDIR "${DEFAULT_ABI}")

# doesn't compile on Darwin
	#make -C "${S}"/src \
	#	CC="$(tc-getCC)" \
	#	LD="$(tc-getCC) ${LDFLAGS}" \
	#	CFLAGS="${CFLAGS}" \
	#	LIBDIR="${libdir}" || die
}

src_install() {
	local dir libdirs libdirs_env rcscripts_dir

	dodir /etc
	dodir /etc/env.d
	dodir /etc/init.d			# .keep file might mess up init.d stuff

	rcscripts_dir="/lib/rcscripts"

	# rc-scripts version for testing of features that *should* be present
	echo "Gentoo Prefixed Base System version ${PV}" > ${ED}/etc/gentoo-release

	# get the basic stuff in there
	doenvd "${S}"/etc/env.d/* || die "doenvd"

	# copy the profile
	cp "${S}"/etc/profile "${ED}"/etc/profile
	
	# Setup files in /sbin
	#
	cd ${S}/sbin
	into /
	# These moved from /etc/init.d/ to /sbin to help newb systems
	# from breaking
	dosbin runscript.sh functions.sh

	# Compat symlinks between /etc/init.d and /sbin
	# (some stuff have hardcoded paths)
	dosym ../../sbin/depscan.sh /etc/init.d/depscan.sh
	dosym ../../sbin/runscript.sh /etc/init.d/runscript.sh
	dosym ../../sbin/functions.sh /etc/init.d/functions.sh

	# We can only install new, fast awk versions of scripts
	# if 'build' or 'bootstrap' is not in USE.  This will
	# change if we have sys-apps/gawk-3.1.1-r1 or later in
	# the build image ...
#	if ! use build; then
		# This is for new depscan.sh and env-update.sh
		# written in awk
		cd "${S}"/sbin
		into /
		dosbin depscan.sh
		dosbin env-update.sh
		insinto ${rcscripts_dir}/awk
		doins "${S}"/src/awk/functions.awk
#	fi

	#
	# Install baselayout utilities
	#
	local libdir="lib"
	[[ ${SYMLINK_LIB} == "yes" ]] && libdir=$(get_abi_LIBDIR "${DEFAULT_ABI}")

# doesn't compile on Darwin
	#cd "${S}"/src
	#make DESTDIR="${D}" LIBDIR="${libdir}" install || die
}

pkg_postinst() {
	# This is also written in src_install (so it's in CONTENTS), but
	# write it here so that the new version is immediately in the file
	# (without waiting for the user to do etc-update)
	rm -f ${EROOT}/etc/._cfg????_gentoo-release
	echo "Gentoo Prefix Base System version ${PV}" > ${EROOT}/etc/gentoo-release

	echo
	einfo "Please be sure to update all pending '._cfg*' files in /etc,"
	einfo "else things might break!  You can use 'etc-update'"
	einfo "to accomplish this:"
	einfo
	einfo "  # etc-update"
	echo
}
