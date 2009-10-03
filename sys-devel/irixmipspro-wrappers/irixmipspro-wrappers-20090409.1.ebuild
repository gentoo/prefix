# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit eutils

DESCRIPTION="A tool to mangle cc/ld arguments to support a Prefix environment"
HOMEPAGE="http://bugs.gentoo.org/show_bug.cgi?id=223351"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
RESTRICT=""

KEYWORDS="~mips-irix"

IUSE=""

DEPEND="sys-devel/binutils-config
	sys-devel/gcc-config"
RDEPEND="${DEPEND}
	sys-apps/coreutils
	sys-apps/sed"

src_install() {
	LDBINPATH=/usr/${CHOST}/binutils-bin/mipspro-${PV}
	CCLIBPATH=/usr/$(get_libdir)/gcc/${CHOST}/mipspro-${PV}
	CCBINPATH=/usr/${CHOST}/gcc-bin/mipspro-${PV}

	keepdir ${LDLIBPATH}
	dodir ${LDBINPATH}
	keepdir ${CCLIBPATH}
	dodir ${CCBINPATH}

	whatld="ld ranlib"
	whatcc="c89 c99 cc CC"

	# copy from the host os
	cd "${ED}${LDBINPATH}"
	cp "${FILESDIR}"/irixmipspro-wrapper-${PV} mipspro-wrapper
	for b in ${ldwhat} ; do
		ln -s mipspro-wrapper ${b}
	done
	cd "${ED}${CCBINPATH}"
	cp "${FILESDIR}"/irixmipspro-wrapper-${PV} mipspro-wrapper
	for b in ${ccwhat} ; do
		ln -s mipspro-wrapper ${b}
	done

	# Generate an env.d entry for binutils-config
	insinto /etc/env.d/binutils
	cat <<-EOF > "${T}"/binutils.env.d
		TARGET="${CHOST}"
		VER="native-${PV}"
		FAKE_TARGETS="${CHOST}"
	EOF
	newins "${T}"/binutils.env.d ${CHOST}-mipspro-${PV}

	# likewise for gcc-config, we don't do multilib
	insinto /etc/env.d/gcc
	cat <<-EOF > "${T}"/gcc.env.d
		LDPATH="${CCLIBPATH}"
		# this is probably wrong for this wrapper
		STDCXX_INCDIR="g++-v${GCC_VERS/\.*/}"
	EOF
	newins "${T}"/gcc.env.d ${CHOST}-mipspro-${PV}
}

pkg_postinst() {
	binutils-config ${CHOST}-mipspro-${PV}
	gcc-config ${CHOST}-mipspro-${PV}
}
