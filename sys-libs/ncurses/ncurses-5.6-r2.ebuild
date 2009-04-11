# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/ncurses/ncurses-5.6-r2.ebuild,v 1.11 2008/04/20 16:53:33 flameeyes Exp $

inherit eutils flag-o-matic toolchain-funcs multilib

MY_PV=${PV:0:3}
PV_SNAP=${PV:4}
MY_P=${PN}-${MY_PV}
DESCRIPTION="console display library"
HOMEPAGE="http://www.gnu.org/software/ncurses/ http://dickey.his.com/ncurses/"
SRC_URI="mirror://gnu/ncurses/${MY_P}.tar.gz
	ftp://invisible-island.net/ncurses/${PV}/${P}-coverity.patch.gz"

LICENSE="MIT"
SLOT="5"
KEYWORDS="~ppc-aix ~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="debug doc gpm minimal nocxx profile trace unicode"

DEPEND="gpm? ( sys-libs/gpm )"

S=${WORKDIR}/${MY_P}

src_unpack() {
	# need libtool to build aix-style shared objects inside archive libs, but
	# cannot depend on libtool, as this would create circular dependencies...
	# And libtool-1.5.26 needs (a similar) patch for AIX (DESTDIR) as found in
	# http://lists.gnu.org/archive/html/bug-libtool/2008-03/msg00124.html
	[[ ${CHOST} == *-aix* ]] && ! type libtool >&/dev/null &&
		die "Please make some working libtool available manually before emerging ncurses"
	unpack ${A}
	cd "${S}"
	[[ -n ${PV_SNAP} ]] && epatch "${WORKDIR}"/${MY_P}-${PV_SNAP}-patch.sh
	epatch "${WORKDIR}"/${P}-coverity.patch
	epatch "${FILESDIR}"/${PN}-5.6-gfbsd.patch
	epatch "${FILESDIR}"/${PN}-5.6-build.patch #184700
	epatch "${FILESDIR}"/${P}-darwin.patch
	epatch "${FILESDIR}"/${PN}-5.6-mint.patch
	epatch "${FILESDIR}"/${PN}-5.5-aix-shared.patch
	epatch "${FILESDIR}"/${P}-solaris2.patch
	epatch "${FILESDIR}"/${P}-interix.patch
	epatch "${FILESDIR}"/${PN}-5.6-netbsd.patch
	epatch "${FILESDIR}"/${P}-libtool.patch # used on aix

	# irix /bin/sh is no good
	find . -name "*.sh" | xargs sed -i -e '1c\#!/usr/bin/env sh'
}

src_compile() {
	[[ ${CHOST} == *-interix* ]] && {
		export ac_cv_func_poll=no
		export ac_cv_header_poll_h=no
	}

	tc-export BUILD_CC

	# Protect the user from themselves #115036
	unset TERMINFO

	local myconf=""
	use nocxx && myconf="${myconf} --without-cxx --without-cxx-binding"
	use ada || myconf="${myconf} --without-ada"
	
	[[ ${CHOST} != *-mint* ]] && myconf="${myconf} --with-shared"
	[[ ${CHOST} == *-aix[5-9]* ]] && myconf="${myconf} --with-libtool"

	# First we build the regular ncurses ...
	mkdir "${WORKDIR}"/narrowc
	cd "${WORKDIR}"/narrowc
	do_compile ${myconf}

	# Then we build the UTF-8 version
	if use unicode ; then
		mkdir "${WORKDIR}"/widec
		cd "${WORKDIR}"/widec
		do_compile ${myconf} --enable-widec --includedir="${EPREFIX}"/usr/include/ncursesw
	fi
}
do_compile() {
	ECONF_SOURCE=${S}

	# We need the basic terminfo files in /etc, bug #37026.  We will
	# add '--with-terminfo-dirs' and then populate /etc/terminfo in
	# src_install() ...
	# The chtype/mmask-t settings below are to retain ABI compat
	# with ncurses-5.4 so dont change em !
	local conf_abi="
		--with-chtype=long \
		--with-mmask-t=long \
		--disable-ext-colors \
		--disable-ext-mouse \
	"
	econf \
		--libdir="${EPREFIX}/usr/$(get_libdir)" \
		--with-terminfo-dirs="${EPREFIX}/etc/terminfo:${EPREFIX}/usr/share/terminfo" \
		--enable-overwrite \
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
		$(use_with !debug leaks) \
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
	[[ ${CHOST} == *-aix* ]] ||
	sed -i -e '/^libdir/s:/usr/lib\(64\|\)$:/lib\1:' ncurses/Makefile || die "nlibdir"

	# A little hack to fix parallel builds ... they break when
	# generating sources so if we generate the sources first (in
	# non-parallel), we can then build the rest of the package
	# in parallel.  This is not really a perf hit since the source
	# generation is quite small.  -vapier
	emake -j1 sources || die "make sources failed"
	emake || die "make failed"
}

src_install() {
	# install unicode version second so that the binaries in /usr/bin
	# support both wide and narrow
	cd "${WORKDIR}"/narrowc
	emake DESTDIR="${D}" install || die "make narrowc install failed"
	if use unicode ; then
		cd "${WORKDIR}"/widec
		emake DESTDIR="${D}" install || die "make widec install failed"
	fi

	if [[ ${CHOST} == *-aix* ]]; then
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
		[[ -f ${ED}/$(get_libdir)/libcursesw$(get_libname) ]] && \
			gen_usr_ldscript libcursesw$(get_libname)
		gen_usr_ldscript libncursesw$(get_libname)
	fi

	# We need the basic terminfo files in /etc, bug #37026
	einfo "Installing basic terminfo files in /etc..."
	for x in ansi console dumb linux rxvt screen sun vt{52,100,102,200,220} \
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

	echo "CONFIG_PROTECT_MASK=\"/etc/terminfo\"" > "${T}"/50ncurses
	doenvd "${T}"/50ncurses

	use minimal && rm -r "${ED}"/usr/share/terminfo
	cd "${S}"
	dodoc ANNOUNCE MANIFEST NEWS README* TO-DO doc/*.doc
	use doc && dohtml -r doc/html/
}

pkg_preinst() {
	use unicode || preserve_old_lib /$(get_libdir)/libncursesw$(get_libname 5)
}

pkg_postinst() {
	use unicode || preserve_old_lib_notify /$(get_libdir)/libncursesw$(get_libname 5)
}
