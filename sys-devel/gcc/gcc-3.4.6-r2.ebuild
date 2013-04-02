# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/gcc-3.4.6-r2.ebuild,v 1.33 2013/01/08 15:27:34 vapier Exp $

PATCH_VER="1.7"
UCLIBC_VER="1.1"
UCLIBC_GCC_VER="3.4.5"
HTB_VER="1.00.1"
HTB_GCC_VER="3.4.4"
D_VER="0.24"

inherit toolchain eutils prefix

DESCRIPTION="The GNU Compiler Collection"

KEYWORDS="~ppc-aix ~amd64-linux ~x86-linux"
IUSE="ip28 ip32r10k n32 n64"

# we need a proper glibc version for the Scrt1.o provided to the pie-ssp specs
# NOTE: we SHOULD be using at least binutils 2.15.90.0.1 everywhere for proper
# .eh_frame ld optimisation and symbol visibility support, but it hasnt been
# well tested in gentoo on any arch other than amd64!!
RDEPEND=""
DEPEND="${RDEPEND}
	|| ( ppc-aix? ( sys-devel/native-cctools )
		>=sys-devel/binutils-2.14.90.0.8-r1
	)
	amd64? ( >=sys-devel/binutils-2.15.90.0.1.1-r1 )"

src_unpack() {
	toolchain_src_unpack

	# misc patches that havent made it into a patch tarball yet
	[[ ${CHOST} == ${CTARGET} ]] && epatch "${FILESDIR}"/gcc-spec-env.patch

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
