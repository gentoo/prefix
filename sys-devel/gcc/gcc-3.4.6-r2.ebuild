# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/gcc-3.4.6-r2.ebuild,v 1.27 2011/09/26 17:38:49 vapier Exp $

MAN_VER=""
PATCH_VER="1.6"
UCLIBC_VER="1.1"
UCLIBC_GCC_VER="3.4.5"
PIE_VER="8.7.10"
PIE_GCC_VER="3.4.6"
PP_VER="1.0"
PP_GCC_VER="3.4.6"
HTB_VER="1.00.1"
HTB_GCC_VER="3.4.4"
D_VER="0.24"

GCC_LIBSSP_SUPPORT="true"

# arch/libc configurations known to be stable with {PIE,SSP}-by-default
SSP_STABLE="x86 sparc amd64 ppc ppc64 ia64"
SSP_UCLIBC_STABLE="arm mips ppc x86"
PIE_GLIBC_STABLE="x86 sparc amd64 ppc ppc64 ia64"
PIE_UCLIBC_STABLE="x86 mips ppc"

# arch/libc configurations known to be broken with {PIE,SSP}-by-default
SSP_UNSUPPORTED=""
SSP_UCLIBC_UNSUPPORTED="${SSP_UNSUPPORTED}"
PIE_UCLIBC_UNSUPPORTED="amd64"
PIE_GLIBC_UNSUPPORTED=""

# whether we should split out specs files for multiple {PIE,SSP}-by-default
# and vanilla configurations.
SPLIT_SPECS=${SPLIT_SPECS-true}

#GENTOO_PATCH_EXCLUDE=""
#PIEPATCH_EXCLUDE=""

inherit toolchain eutils prefix

DESCRIPTION="The GNU Compiler Collection"

KEYWORDS="~ppc-aix ~amd64-linux ~x86-linux"
IUSE="ip28 ip32r10k n32 n64"

# we need a proper glibc version for the Scrt1.o provided to the pie-ssp specs
# NOTE: we SHOULD be using at least binutils 2.15.90.0.1 everywhere for proper
# .eh_frame ld optimisation and symbol visibility support, but it hasnt been
# well tested in gentoo on any arch other than amd64!!
RDEPEND=">=sys-devel/gcc-config-1.4
	>=sys-libs/zlib-1.1.4
	virtual/libiconv
	!prefix? ( elibc_glibc? (
		>=sys-libs/glibc-2.3.3_pre20040420-r1
		hardened? ( >=sys-libs/glibc-2.3.3_pre20040529 )
	) )
	!build? (
		gcj? (
			gtk? (
				x11-libs/libXt
				x11-libs/libX11
				x11-libs/libXtst
				x11-proto/xproto
				x11-proto/xextproto
				=x11-libs/gtk+-2*
			)
			>=media-libs/libart_lgpl-2.1
		)
		>=sys-libs/ncurses-5.2-r2
		nls? ( sys-devel/gettext )
	)"

if [[ ${CATEGORY/cross-} != ${CATEGORY} ]]; then
	RDEPEND="${RDEPEND} ${CATEGORY}/binutils"
fi

DEPEND="${RDEPEND}
	>=sys-apps/texinfo-4.2-r4
	>=sys-devel/bison-1.875
	sys-devel/flex
	|| ( ppc-aix? ( sys-devel/native-cctools )
		>=sys-devel/binutils-2.14.90.0.8-r1
	)
	amd64? ( >=sys-devel/binutils-2.15.90.0.1.1-r1 )"
PDEPEND=">=sys-devel/gcc-config-1.4"

src_unpack() {
	toolchain_src_unpack

	# misc patches that havent made it into a patch tarball yet
	[[ ${CHOST} == ${CTARGET} ]] && epatch "${FILESDIR}"/gcc-spec-env.patch

	# nothing in the tree provides libssp.so, so nothing will ever trigger this
	# logic, but having the patch in the tree makes life so much easier for me
	# since I dont have to also have an overlay for this.
	want_libssp && epatch "${FILESDIR}"/3.4.3/libssp.patch

	# Anything useful and objc will require libffi. Seriously. Lets just force
	# libffi to install with USE="objc", even though it normally only installs
	# if you attempt to build gcj.
	if ! use build && use objc && ! use gcj ; then
		epatch "${FILESDIR}"/3.4.3/libffi-without-libgcj.patch
		#epatch ${FILESDIR}/3.4.3/libffi-nogcj-lib-path-fix.patch
	fi

	# Fix cross-compiling
	epatch "${FILESDIR}"/3.4.4/gcc-3.4.4-cross-compile.patch

	# http://gcc.gnu.org/PR20366
	epatch "${FILESDIR}"/${P}-aix-largefiles.patch

	# Always behave as if -pthread were passed on AIX (#266548)
	epatch "${FILESDIR}"/3.4.4/aix-force-pthread.patch

	# Always behave as if -Wl,-brtl were passed on AIX (#213277)
	epatch "${FILESDIR}"/3.4.4/aix-runtimelinking.patch

	# AIX 5.3 TL08 binder dumps core for unknown reason (#265540),
	# adding -bexpfull seems to help.
	if [[ ${CTARGET} == *-aix5.3* ]]; then
		epatch "${FILESDIR}"/3.4.4/aix5300-08_ldcore.patch
	fi

	# replace nasty multilib dirs like ../lib64 that occur on --disable-multilib
	if use prefix; then
		epatch "${FILESDIR}"/3.4.4/prefix-search-dirs.patch
		eprefixify "${S}"/gcc/gcc.c
	fi

	[[ ${CTARGET} == *-softfloat-* ]] && epatch "${FILESDIR}"/3.4.4/gcc-3.4.4-softfloat.patch

	# Arch stuff
	case $(tc-arch) in
		amd64)
			if is_multilib ; then
				sed -i -e '/GLIBCXX_IS_NATIVE=/s:false:true:' libstdc++-v3/configure || die
			fi
			;;
	esac
}

src_compile() {
	toolchain_src_compile

	if [[ ${CTARGET} == *-aix* ]]; then
		# Default to -mminimal-toc on AIX, gdb does not like bigtoc (#266483).
		einfo "adding -mminimal-toc to specs for AIX"
		sed -i -e '/^\*cc1_options:$/{n; s,^,-mminimal-toc ,}' \
			"${WORKDIR}"/build/gcc/specs || die "cannot add -mminimal-toc to aix specs"
		eend
	fi
}
