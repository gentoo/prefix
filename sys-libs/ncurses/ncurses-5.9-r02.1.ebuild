# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/ncurses/ncurses-5.9-r2.ebuild,v 1.16 2012/10/23 20:07:18 vapier Exp $

EAPI="1"
AUTOTOOLS_AUTO_DEPEND="no"
inherit eutils flag-o-matic toolchain-funcs autotools

MY_PV=${PV:0:3}
PV_SNAP=${PV:4}
MY_P=${PN}-${MY_PV}
DESCRIPTION="console display library"
HOMEPAGE="http://www.gnu.org/software/ncurses/ http://dickey.his.com/ncurses/"
SRC_URI="mirror://gnu/ncurses/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="5"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="ada +cxx debug doc gpm minimal profile static-libs trace unicode"

DEPEND="gpm? ( sys-libs/gpm )
	kernel_AIX? ( ${AUTOTOOLS_DEPEND} )
	kernel_HPUX? ( ${AUTOTOOLS_DEPEND} )"
#	berkdb? ( sys-libs/db )"
RDEPEND="${DEPEND}
	!<x11-terms/rxvt-unicode-9.06-r3"

S=${WORKDIR}/${MY_P}

need-libtool() {
	# need libtool to build aix-style shared objects inside archive libs, but
	# cannot depend on libtool, as this would create circular dependencies...
	# And libtool-1.5.26 needs (a similar) patch for AIX (DESTDIR) as found in
	# http://lists.gnu.org/archive/html/bug-libtool/2008-03/msg00124.html
	# Use libtool on hpux too to get some soname.
	[[ ${CHOST} == *'-aix'* || ${CHOST} == *'-hpux'* ]]
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	[[ -n ${PV_SNAP} ]] && epatch "${WORKDIR}"/${MY_P}-${PV_SNAP}-patch.sh
	epatch "${FILESDIR}"/${PN}-5.8-gfbsd.patch
	epatch "${FILESDIR}"/${PN}-5.7-nongnu.patch
	epatch "${FILESDIR}"/${PN}-5.9-rxvt-unicode-9.15.patch #192083 #383871
	epatch "${FILESDIR}"/${PN}-5.9-fix-clang-build.patch #417763

	epatch "${FILESDIR}"/${PN}-5.5-aix-shared.patch
	epatch "${FILESDIR}"/${PN}-5.6-interix.patch

	# /bin/sh is not always good enough
	find . -name "*.sh" | xargs sed -i -e '1c\#!/usr/bin/env sh'

	if need-libtool; then
		mkdir "${WORKDIR}"/local-libtool || die
		cd "${WORKDIR}"/local-libtool || die
		cat >configure.ac<<-EOF
			AC_INIT(local-libtool, 0)
			AC_PROG_CC
			AC_PROG_CXX
			AC_PROG_LIBTOOL
			AC_OUTPUT
		EOF
		eautoreconf
	fi

	# Don't mess with _XOPEN_SOURCE for C++ on (Open)Solaris.  The compiler
	# defines a value for it, and depending on version, a different definition
	# is used.  Defining this variable on these systems is dangerous any time,
	# since the system headers do strict checks on compatability of flags and
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

src_compile() {
	if need-libtool; then
		cd "${WORKDIR}"/local-libtool || die
		econf
		export PATH="${WORKDIR}"/local-libtool:${PATH}
		cd "${S}" || die
	fi

	unset TERMINFO #115036
	tc-export_build_env BUILD_{CC,CPP}
	BUILD_CPPFLAGS+=" -D_GNU_SOURCE" #214642

	# when cross-compiling, we need to build up our own tic
	# because people often don't keep matching host/target
	# ncurses versions #249363
	if tc-is-cross-compiler && ! ROOT=/ has_version ~sys-libs/${P} ; then
		make_flags="-C progs tic"
		CHOST=${CBUILD} \
		CFLAGS=${BUILD_CFLAGS} \
		CXXFLAGS=${BUILD_CXXFLAGS} \
		CPPFLAGS=${BUILD_CPPFLAGS} \
		LDFLAGS="${BUILD_LDFLAGS} -static" \
		do_compile cross --without-shared --with-normal
	fi

	make_flags=""
	do_compile narrowc
	use unicode && do_compile widec --enable-widec --includedir="${EPREFIX}"/usr/include/ncursesw
}
do_compile() {
	ECONF_SOURCE=${S}

	mkdir "${WORKDIR}"/$1
	cd "${WORKDIR}"/$1
	shift

	# ncurses is dumb and doesn't install .pc files unless pkg-config
	# is also installed.  Force the tests to go our way.  Note that it
	# doesn't actually use pkg-config ... it just looks for set vars.
	tc-export PKG_CONFIG
	export PKG_CONFIG_LIBDIR="/usr/$(get_libdir)/pkgconfig"

	# The chtype/mmask-t settings below are to retain ABI compat
	# with ncurses-5.4 so dont change em !
	local conf_abi="
		--with-chtype=long \
		--with-mmask-t=long \
		--disable-ext-colors \
		--disable-ext-mouse \
		--without-pthread \
		--without-reentrant \
	"

	local myconf=""
	if need-libtool; then
		myconf="${myconf} --with-libtool"
	elif [[ ${CHOST} == *-mint* ]]; then
		:
	else
		myconf="--with-shared"
	fi

	if [[ ${CHOST} == *-interix* ]]; then
		myconf="--without-leaks"
	fi

	# We need the basic terminfo files in /etc, bug #37026.  We will
	# add '--with-terminfo-dirs' and then populate /etc/terminfo in
	# src_install() ...
#		$(use_with berkdb hashed-db)
	econf \
		--libdir="${EPREFIX}/usr/$(get_libdir)" \
		--with-terminfo-dirs="${EPREFIX}/etc/terminfo:${EPREFIX}/usr/share/terminfo" \
		${myconf} \
		--without-hashed-db \
		--enable-overwrite \
		$(use_with ada) \
		$(use_with cxx) \
		$(use_with cxx cxx-binding) \
		$(use_with debug) \
		$(use_with profile) \
		$(use_with gpm) \
		--disable-termcap \
		--enable-symlinks \
		--with-rcs-ids \
		--with-manpage-format=normal \
		--enable-const \
		--enable-colorfgbg \
		--enable-echo \
		--enable-pc-files \
		$(use_enable !ada warnings) \
		$(use_with debug assertions) \
		$(use_enable debug leaks) \
		$(use_with debug expanded) \
		$(use_with !debug macros) \
		$(use_with trace) \
		${conf_abi} \
		"$@"

	# A little hack to fix parallel builds ... they break when
	# generating sources so if we generate the sources first (in
	# non-parallel), we can then build the rest of the package
	# in parallel.  This is not really a perf hit since the source
	# generation is quite small.
	emake -j1 sources || die
	# For some reason, sources depends on pc-files which depends on
	# compiled libraries which depends on sources which ...
	# Manually delete the pc-files file so the install step will
	# create the .pc files we want.
	rm -f misc/pc-files
	emake ${make_flags} || die
}

src_install() {
	# use the cross-compiled tic (if need be) #249363
	export PATH=${WORKDIR}/cross/progs:${PATH}

	# install unicode version second so that the binaries in /usr/bin
	# support both wide and narrow
	cd "${WORKDIR}"/narrowc
	emake DESTDIR="${D}" install || die
	if use unicode ; then
		cd "${WORKDIR}"/widec
		emake DESTDIR="${D}" install || die
	fi

	if need-libtool; then
		# Move dynamic ncurses libraries into /lib
		dodir /$(get_libdir)
		local f
		for f in "${ED}"usr/$(get_libdir)/lib{,n}curses{,w}$(get_libname)*; do
			[[ -f ${f} ]] || continue
			mv "${f}" "${ED}"$(get_libdir)/ || die "could not move ${f#${ED}}"
		done
	else # keeping intendation to keep diff small
	# Move static and extraneous ncurses static libraries out of /lib
	cd "${ED}"/$(get_libdir)
	mv *.a "${ED}"/usr/$(get_libdir)/
	fi
	gen_usr_ldscript -a ncurses
	use unicode && gen_usr_ldscript -a ncursesw
	if ! tc-is-static-only ; then
		ln -sf libncurses$(get_libname) "${ED}"/usr/$(get_libdir)/libcurses$(get_libname) || die
	fi
	use static-libs || find "${D}"/usr/ -name '*.a' -a '!' -name '*curses++*.a' -delete

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

		# Build fails to create this ...
		dosym ../share/terminfo /usr/$(get_libdir)/terminfo
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
