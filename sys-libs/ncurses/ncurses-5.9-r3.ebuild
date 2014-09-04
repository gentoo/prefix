# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/ncurses/ncurses-5.9-r3.ebuild,v 1.16 2014/07/13 19:30:57 zlogene Exp $

EAPI="4"
inherit eutils flag-o-matic toolchain-funcs multilib-minimal libtool

MY_PV=${PV:0:3}
PV_SNAP=${PV:4}
MY_P=${PN}-${MY_PV}
DESCRIPTION="console display library"
HOMEPAGE="http://www.gnu.org/software/ncurses/ http://dickey.his.com/ncurses/"
SRC_URI="mirror://gnu/ncurses/${MY_P}.tar.gz"

HOSTLTV="0.1.0"
HOSTLT="host-libtool-${HOSTLTV}"
HOSTLT_URI="http://github.com/haubi/host-libtool/releases/download/v${HOSTLTV}/${HOSTLT}.tar.gz"
SRC_URI="${SRC_URI}
	kernel_AIX? ( ${HOSTLT_URI} )
	kernel_HPUX? ( ${HOSTLT_URI} )
"

LICENSE="MIT"
SLOT="5"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="ada +cxx debug doc gpm minimal profile static-libs tinfo trace unicode"

DEPEND="gpm? ( sys-libs/gpm )"
#	berkdb? ( sys-libs/db )"
RDEPEND="${DEPEND}
	!<x11-terms/rxvt-unicode-9.06-r3
	abi_x86_32? (
		!<=app-emulation/emul-linux-x86-baselibs-20130224-r12
		!app-emulation/emul-linux-x86-baselibs[-abi_x86_32(-)]
	)"
# Put the MULTILIB_USEDEP on gpm in PDEPEND only to avoid circular deps.
# We can move it to DEPEND and drop the --with-gpm=libgpm.so.1 from the econf
# line below once we can assume multilib gpm is available everywhere.
PDEPEND="gpm? ( sys-libs/gpm[${MULTILIB_USEDEP}] )"

S=${WORKDIR}/${MY_P}
HOSTTIC_DIR=${WORKDIR}/${P}-host

need-libtool() {
	# need libtool to build aix-style shared objects inside archive libs, but
	# cannot depend on libtool, as this would create circular dependencies...
	# And libtool-1.5.26 needs (a similar) patch for AIX (DESTDIR) as found in
	# http://lists.gnu.org/archive/html/bug-libtool/2008-03/msg00124.html
	# Use libtool on hpux too to get some soname.
	[[ ${CHOST} == *'-aix'* || ${CHOST} == *'-hpux'* ]]
}

src_prepare() {
	[[ -n ${PV_SNAP} ]] && epatch "${WORKDIR}"/${MY_P}-${PV_SNAP}-patch.sh
	epatch "${FILESDIR}"/${PN}-5.8-gfbsd.patch
	epatch "${FILESDIR}"/${PN}-5.7-nongnu.patch
	epatch "${FILESDIR}"/${PN}-5.9-rxvt-unicode-9.15.patch #192083 #383871
	epatch "${FILESDIR}"/${PN}-5.9-fix-clang-build.patch #417763
	epatch "${FILESDIR}"/${PN}-5.9-pkg-config.patch

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

	# when cross-compiling, we need to build up our own tic
	# because people often don't keep matching host/target
	# ncurses versions #249363
	if tc-is-cross-compiler && ! ROOT=/ has_version ~sys-libs/${P} ; then
		CHOST=${CBUILD} \
		CFLAGS=${BUILD_CFLAGS} \
		CXXFLAGS=${BUILD_CXXFLAGS} \
		CPPFLAGS=${BUILD_CPPFLAGS} \
		LDFLAGS="${BUILD_LDFLAGS} -static" \
		BUILD_DIR="${HOSTTIC_DIR}" do_configure cross --without-shared --with-normal
	fi
	multilib-minimal_src_configure
}

multilib_src_configure() {
	do_configure narrowc --includedir="${EPREFIX}"/usr/include
	use unicode && do_configure widec --enable-widec --includedir="${EPREFIX}"/usr/include/ncursesw
}

do_configure() {
	ECONF_SOURCE=${S}

	mkdir "${BUILD_DIR}"-$1
	cd "${BUILD_DIR}"-$1 || die
	shift

	local conf=(
		# We need the basic terminfo files in /etc, bug #37026.  We will
		# add '--with-terminfo-dirs' and then populate /etc/terminfo in
		# src_install() ...
		--with-terminfo-dirs="${EPREFIX}/etc/terminfo:${EPREFIX}/usr/share/terminfo"

		# Disabled until #245417 is sorted out.
		#$(use_with berkdb hashed-db)

		# ncurses is dumb and doesn't install .pc files unless pkg-config
		# is also installed.  Force the tests to go our way.  Note that it
		# doesn't actually use pkg-config ... it just looks for set vars.
		--enable-pc-files
		--with-pkg-config="$(tc-getPKG_CONFIG)"
		# This path is used to control where the .pc files are installed.
		PKG_CONFIG_LIBDIR="${EPREFIX}/usr/$(get_libdir)/pkgconfig"

		# Now the rest of the various standard flags.
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
		$(use_with ada)
		$(use_with cxx)
		$(use_with cxx cxx-binding)
		$(use_with debug)
		$(use_with profile)
		$(use_with gpm)
		$(multilib_is_native_abi || use_with gpm gpm libgpm.so.1)
		--disable-termcap
		--enable-symlinks
		--with-rcs-ids
		--with-manpage-format=normal
		--enable-const
		--enable-colorfgbg
		--enable-echo
		$(use_enable !ada warnings)
		$(use_with debug assertions)
		$(use_enable debug leaks)
		$(use_with debug expanded)
		$(use_with !debug macros)
		$(use_with trace)
		$(use_with tinfo termlib)

		# The chtype/mmask-t settings below are to retain ABI compat
		# with ncurses-5.4 so dont change em !
		--with-chtype=long
		--with-mmask-t=long
		--disable-ext-colors
		--disable-ext-mouse
		--without-pthread
		--without-reentrant
	)

	econf "${conf[@]}" "$@"
}

src_compile() {
	# when cross-compiling, we need to build up our own tic
	# because people often don't keep matching host/target
	# ncurses versions #249363
	if tc-is-cross-compiler && ! ROOT=/ has_version ~sys-libs/${P} ; then
		make_flags="-C progs tic"
		BUILD_DIR="${HOSTTIC_DIR}" do_compile cross
	fi

	multilib-minimal_src_compile
}

multilib_src_compile() {
	make_flags=""
	multilib_is_native_abi || make_flags="PROGS= "
	do_compile narrowc
	use unicode && do_compile widec
}

do_compile() {
	cd "${BUILD_DIR}"-$1 || die

	# A little hack to fix parallel builds ... they break when
	# generating sources so if we generate the sources first (in
	# non-parallel), we can then build the rest of the package
	# in parallel.  This is not really a perf hit since the source
	# generation is quite small.
	emake -j1 sources
	# For some reason, sources depends on pc-files which depends on
	# compiled libraries which depends on sources which ...
	# Manually delete the pc-files file so the install step will
	# create the .pc files we want.
	rm -f misc/pc-files
	emake ${make_flags}
}

multilib_src_install() {
	# use the cross-compiled tic (if need be) #249363
	export PATH="${HOSTTIC_DIR}-cross/progs:${PATH}"

	# install unicode version second so that the binaries in /usr/bin
	# support both wide and narrow
	cd "${BUILD_DIR}"-narrowc || die
	emake DESTDIR="${D}" install
	if use unicode ; then
		cd "${BUILD_DIR}"-widec || die
		emake DESTDIR="${D}" install
	fi

	# Move libncurses{,w} into /lib
	multilib_is_native_abi && gen_usr_ldscript -a \
		ncurses \
		$(usex unicode 'ncursesw' '') \
		$(use tinfo && usex unicode 'tinfow' '') \
		$(usev tinfo)
	if ! tc-is-static-only ; then
		ln -sf libncurses$(get_libname) "${ED}"/usr/$(get_libdir)/libcurses$(get_libname) || die
	fi
	use static-libs || find "${ED}"/usr/ -name '*.a' -a '!' -name '*curses++*.a' -delete

	# Build fails to create this ...
	dosym ../share/terminfo /usr/$(get_libdir)/terminfo
}

multilib_src_install_all() {
#	if ! use berkdb ; then
		# We need the basic terminfo files in /etc, bug #37026
		einfo "Installing basic terminfo files in /etc..."
		for x in ansi console dumb linux rxvt rxvt-unicode screen sun vt{52,100,102,200,220} \
				 xterm xterm-color xterm-xfree86
		do
			local termfile=$(find "${ED}"/usr/share/terminfo/ -name "${x}" 2>/dev/null)
			local basedir=$(basename $(dirname "${termfile}"))

			if [[ -n ${termfile} ]] ; then
				dodir /etc/terminfo/${basedir}
				mv ${termfile} "${ED}"/etc/terminfo/${basedir}/
				dosym ../../../../etc/terminfo/${basedir}/${x} \
					/usr/share/terminfo/${basedir}/${x}
			fi
		done
#	fi

	echo "CONFIG_PROTECT_MASK=\"/etc/terminfo\"" > "${T}"/50ncurses
	doenvd "${T}"/50ncurses

	use minimal && rm -r "${ED}"/usr/share/terminfo*
	# Because ncurses5-config --terminfo returns the directory we keep it
	keepdir /usr/share/terminfo #245374

	cd "${S}"
	dodoc ANNOUNCE MANIFEST NEWS README* TO-DO doc/*.doc
	use doc && dohtml -r doc/html/
}
