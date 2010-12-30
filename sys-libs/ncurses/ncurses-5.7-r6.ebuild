# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/ncurses/ncurses-5.7-r6.ebuild,v 1.1 2010/11/15 11:55:07 wired Exp $

EAPI="1"
AUTOTOOLS_AUTO_DEPEND="no"
inherit eutils flag-o-matic toolchain-funcs multilib autotools

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
RDEPEND="!<x11-terms/rxvt-unicode-9.06-r3"

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
	epatch "${FILESDIR}"/${PN}-5.6-gfbsd.patch
	epatch "${FILESDIR}"/${PN}-5.7-emacs.patch #270527
	epatch "${FILESDIR}"/${PN}-5.7-nongnu.patch
	epatch "${FILESDIR}"/${PN}-5.7-tic-cross-detection.patch #288881
	epatch "${FILESDIR}"/${PN}-5.7-rxvt-unicode-9.09.patch #192083
	epatch "${FILESDIR}"/${P}-hashdb-open.patch #245370
	sed -i '/with_no_leaks=yes/s:=.*:=$enableval:' configure #305889

	epatch "${FILESDIR}"/${PN}-5.7-mint.patch
	epatch "${FILESDIR}"/${PN}-5.7-mint-terminfo.patch
	epatch "${FILESDIR}"/${PN}-5.5-aix-shared.patch
	epatch "${FILESDIR}"/${PN}-5.6-interix.patch
	epatch "${FILESDIR}"/${PN}-5.6-netbsd.patch
#	epatch "${FILESDIR}"/${PN}-5.6-libtool.patch # used on aix
	epatch "${FILESDIR}"/${PN}-5.7-x64-freebsd.patch
	epatch "${FILESDIR}"/${PN}-5.7-ldflags-with-libtool.patch

	# irix /bin/sh is no good
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
}

src_compile() {
	if need-libtool; then
		cd "${WORKDIR}"/local-libtool || die
		econf
		export PATH="${WORKDIR}"/local-libtool:${PATH}
		cd "${S}" || die
	fi

	unset TERMINFO #115036
	tc-export BUILD_CC
	export BUILD_CPPFLAGS+=" -D_GNU_SOURCE" #214642

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
		myconf="--with-shared $(use_enable static-libs normal)"
	fi

	if [[ ${CHOST} == *-interix* ]]; then
		myconf="--without-leaks"
	fi

	# We need the basic terminfo files in /etc, bug #37026.  We will
	# add '--with-terminfo-dirs' and then populate /etc/terminfo in
	# src_install() ...
#		$(use_with berkdb hashed-db) \
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
		$(use_enable !ada warnings) \
		$(use_with debug assertions) \
		$(use_enable debug leaks) \
		$(use_with debug expanded) \
		$(use_with !debug macros) \
		$(use_with trace) \
		${conf_abi} \
		"$@" \
		|| die "configure failed"

	[[ ${CHOST} == *-solaris* ]] && \
		sed -i -e 's/-D_XOPEN_SOURCE_EXTENDED//g' c++/Makefile

	# Fix for install location of the lib{,n}curses{,w} libs as in Gentoo we
	# want those in lib not usr/lib.  We cannot move them lateron after
	# installing, because that will result in broken install_names for
	# platforms that store pointers to the libs instead of directories.
	# But this only is true when building without libtool.
	need-libtool ||
	sed -i -e '/^libdir/s:/usr/lib\(64\|\)$:/lib\1:' ncurses/Makefile || die "nlibdir"

	# for IRIX to get tests compiling
	epatch "${FILESDIR}"/${PN}-5.7-irix.patch

	# A little hack to fix parallel builds ... they break when
	# generating sources so if we generate the sources first (in
	# non-parallel), we can then build the rest of the package
	# in parallel.  This is not really a perf hit since the source
	# generation is quite small.  -vapier
	emake -j1 sources || die "make sources failed"
	emake ${make_flags} || die "make ${make_flags} failed"
}

src_install() {
	# use the cross-compiled tic (if need be) #249363
	export PATH=${WORKDIR}/cross/progs:${PATH}

	# install unicode version second so that the binaries in /usr/bin
	# support both wide and narrow
	cd "${WORKDIR}"/narrowc
	emake DESTDIR="${D}" install || die "make narrowc install failed"
	if use unicode ; then
		cd "${WORKDIR}"/widec
		emake DESTDIR="${D}" install || die "make widec install failed"
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
	gen_usr_ldscript lib{,n}curses$(get_libname)
	if use unicode ; then
		gen_usr_ldscript libncursesw$(get_libname)
	fi
	ln -sf libncurses$(get_libname) "${ED}"/usr/$(get_libdir)/libcurses.$(get_libname)

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
