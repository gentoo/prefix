# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# This version is just for the ABI .5 library

EAPI="5"

inherit eutils toolchain-funcs multilib-minimal multiprocessing flag-o-matic libtool

MY_PV=${PV:0:3}
MY_P=${PN}-${MY_PV}
DESCRIPTION="console display library"
HOMEPAGE="https://www.gnu.org/software/ncurses/ http://dickey.his.com/ncurses/"
SRC_URI="mirror://gnu/ncurses/${MY_P}.tar.gz"

HOSTLTV="0.1.0"
HOSTLT="host-libtool-${HOSTLTV}"
HOSTLT_URI="http://github.com/haubi/host-libtool/releases/download/v${HOSTLTV}/${HOSTLT}.tar.gz"
SRC_URI="${SRC_URI}
	kernel_AIX? ( ${HOSTLT_URI} )
	kernel_HPUX? ( ${HOSTLT_URI} )
"

LICENSE="MIT"
# The subslot reflects the SONAME.
SLOT="5/5"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="gpm tinfo unicode"

DEPEND="gpm? ( sys-libs/gpm[${MULTILIB_USEDEP}] )"
# Block the ncurses-5 that installs the same lib. #557472
RDEPEND="${DEPEND}
	!<sys-libs/ncurses-6:0"

S=${WORKDIR}/${MY_P}

PATCHES=(
	"${FILESDIR}"/${PN}-5.8-gfbsd.patch
	"${FILESDIR}"/${PN}-5.7-nongnu.patch
	"${FILESDIR}"/${PN}-5.9-rxvt-unicode-9.15.patch #192083 #383871
	"${FILESDIR}"/${PN}-5.9-fix-clang-build.patch #417763
	"${FILESDIR}"/${PN}-5.9-pkg-config.patch
	"${FILESDIR}"/${P}-no-I-usr-include.patch #522586
	"${FILESDIR}"/${P}-gcc-5.patch #545114
)

need-libtool() {
	# need libtool to build aix-style shared objects inside archive libs, but
	# cannot depend on libtool, as this would create circular dependencies...
	# And libtool-1.5.26 needs (a similar) patch for AIX (DESTDIR) as found in
	# http://lists.gnu.org/archive/html/bug-libtool/2008-03/msg00124.html
	# Use libtool on hpux too to get some soname.
	[[ ${CHOST} == *'-aix'* || ${CHOST} == *'-hpux'* ]]
}

src_prepare() {
	epatch "${PATCHES[@]}"

	# /bin/sh is not always good enough
	find . -name "*.sh" | xargs sed -i -e '1c\#!/usr/bin/env sh'

	if need-libtool; then
		S="${WORKDIR}"/${HOSTLT} elibtoolize

		# Don't need local libraries (-L../lib) for libncurses,
		# ends up as insecure runpath in libncurses.so[shr.o] on AIX
		sed -i -e '/^SHLIB_LIST[ \t]*=/s/\$(SHLIB_DIRS)//' ncurses/Makefile.in || die
	fi

	# Don't mess with _XOPEN_SOURCE for C++ on (Open)Solaris.  The compiler
	# defines a value for it, and depending on version, a different definition
	# is used.  Defining this variable on these systems is dangerous any time,
	# since the system headers do strict checks on compatibility of flags and
	# standards.
	# Defining _XOPEN_SOURCE_EXTENDED together with _XOPEN_SOURCE leads to
	# pre-_XOPEN_SOURCE=500 stuff, so only do it for non-C++ code.
	# See also bug #431352
	if [[ ${CHOST} == *-solaris* ]] ; then
		sed -i \
			-e '/-D__EXTENSIONS__/ s/-D_XOPEN_SOURCE=\$cf_XOPEN_SOURCE//' \
			-e '/CPPFLAGS="$CPPFLAGS/s/ -D_XOPEN_SOURCE_EXTENDED//' \
			configure || die
		# ONLY in C-mode, NOT C++
		append-cflags -D_XOPEN_SOURCE_EXTENDED
	fi
}

src_configure() {
	if need-libtool; then
		cd "${WORKDIR}"/${HOSTLT} || die
		econf
		export PATH="${WORKDIR}"/${HOSTLT}:${PATH}
		cd "${S}" || die
	fi

	unset TERMINFO #115036
	tc-export_build_env BUILD_{CC,CPP}
	BUILD_CPPFLAGS+=" -D_GNU_SOURCE" #214642

	# Build the various variants of ncurses -- narrow, wide, and threaded. #510440
	# Order matters here -- we want unicode/thread versions to come last so that the
	# binaries in /usr/bin support both wide and narrow.
	# The naming is also important as we use these directly with filenames and when
	# checking configure flags.
	NCURSES_TARGETS=(
		ncurses
		$(usex unicode 'ncursesw' '')
	)

	multijob_init

	# When installing ncurses, we have to use a compatible version of tic.
	# This comes up when cross-compiling, doing multilib builds, upgrading,
	# or installing for the first time.  Build a local copy of tic whenever
	# the host version isn't available. #249363 #557598
	if ! ROOT=/ has_version "~sys-libs/${P}" ; then
		local lbuildflags="-static"

		# some toolchains don't quite support static linking
		local dbuildflags="-Wl,-rpath,${WORKDIR}/lib"
		case ${CHOST} in
			*-darwin*)  dbuildflags=     ;;
		esac
		echo "int main() {}" | \
			$(tc-getCC) -o x -x c - ${lbuildflags} -pipe >& /dev/null \
			|| lbuildflags="${dbuildflags}"

		# We can't re-use the multilib BUILD_DIR because we run outside of it.
		BUILD_DIR="${WORKDIR}" \
		CHOST=${CBUILD} \
		CFLAGS=${BUILD_CFLAGS} \
		CXXFLAGS=${BUILD_CXXFLAGS} \
		CPPFLAGS=${BUILD_CPPFLAGS} \
		LDFLAGS="${BUILD_LDFLAGS} ${lbuildflags}" \
		multijob_child_init do_configure cross --without-shared --with-normal
	fi
	multilib-minimal_src_configure
	multijob_finish
}

multilib_src_configure() {
	local t
	for t in "${NCURSES_TARGETS[@]}" ; do
		multijob_child_init do_configure "${t}"
	done
}

do_configure() {
	local target=$1
	shift

	mkdir "${BUILD_DIR}/${target}"
	cd "${BUILD_DIR}/${target}" || die

	local conf=(
		# We need the basic terminfo files in /etc, bug #37026.  We will
		# add '--with-terminfo-dirs' and then populate /etc/terminfo in
		# src_install() ...
		--with-terminfo-dirs="${EPREFIX}/etc/terminfo:${EPREFIX}/usr/share/terminfo"

		# Now the rest of the various standard flags.
		--without-hashed-db
		--disable-pc-files
		--$(
			if need-libtool ; then
				echo with-libtool
			elif tc-is-static-only ; then
				echo without-shared
			else
				echo with-shared
			fi
		)
		--without-hashed-db
		--without-ada
		--without-cxx
		--without-cxx-binding
		--without-debug
		--without-profile
		# The configure script uses ldd to parse the linked output which
		# is flaky for cross-compiling/multilib/ldd versions/etc...
		$(use_with gpm gpm libgpm.so.1)
		--disable-termcap
		--enable-symlinks
		--with-rcs-ids
		--with-manpage-format=normal
		--enable-const
		--enable-colorfgbg
		--enable-echo
		--disable-warnings
		--without-assertions
		--enable-leaks
		--without-expanded
		--with-macros
		--without-progs
		--without-tests
		--without-trace
		$(use_with tinfo termlib)

		# The chtype/mmask-t settings below are to retain ABI compat
		# with ncurses-5.4 so dont change em !
		--with-chtype=long
		--with-mmask-t=long
		--disable-ext-colors
		--disable-ext-mouse
		--without-{pthread,reentrant}
	)

	if [[ ${target} == ncurses*w ]] ; then
		conf+=( --enable-widec )
	else
		conf+=( --disable-widec )
	fi
	# Make sure each variant goes in a unique location.
	if [[ ${target} != "ncurses" ]] ; then
		conf+=( --includedir="${EPREFIX}"/usr/include/${target} )
	fi
	# See comments in src_configure.
	if [[ ${target} != "cross" ]] ; then
		local cross_path="${WORKDIR}/cross"
		[[ -d ${cross_path} ]] && export TIC_PATH="${cross_path}/progs/tic"
	else
		conf+=( --with-progs )
	fi

	# Force bash until upstream rebuilds the configure script with a newer
	# version of autotools. #545532
	CONFIG_SHELL=${BASH} \
	ECONF_SOURCE=${S} \
	econf "${conf[@]}" "$@"
}

src_compile() {
	# See comments in src_configure.
	if ! ROOT=/ has_version "~sys-libs/${P}" ; then
		BUILD_DIR="${WORKDIR}" \
		do_compile cross -C progs tic
	fi

	multilib-minimal_src_compile
}

multilib_src_compile() {
	local t
	for t in "${NCURSES_TARGETS[@]}" ; do
		do_compile "${t}"
	done
}

do_compile() {
	local target=$1
	shift

	cd "${BUILD_DIR}/${target}" || die

	# A little hack to fix parallel builds ... they break when
	# generating sources so if we generate the sources first (in
	# non-parallel), we can then build the rest of the package
	# in parallel.  This is not really a perf hit since the source
	# generation is quite small.
	emake -j1 sources
	emake "$@"
}

multilib_src_install() {
	local target lib
	for target in "${NCURSES_TARGETS[@]}" ; do
		cd "${BUILD_DIR}/${target}/lib" || die
		for lib in *$(get_libname 5.9) ; do
			newlib.so "${lib}" "${lib%%.9}"
		done
	done
}
