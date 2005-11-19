# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/ncurses/ncurses-5.5.ebuild,v 1.1 2005/10/20 04:59:06 vapier Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs

MY_PV=${PV:0:3}
PV_SNAP=${PV:4}
MY_P=${PN}-${MY_PV}
DESCRIPTION="console display library"
HOMEPAGE="http://www.gnu.org/software/ncurses/ http://dickey.his.com/ncurses/"
SRC_URI="mirror://gnu/ncurses/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="5"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc-macos ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="gpm build bootstrap debug doc minimal unicode nocxx"

DEPEND="gpm? ( sys-libs/gpm )"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	[[ -n ${PV_SNAP} ]] && epatch "${WORKDIR}"/${MY_P}-${PV_SNAP}-patch.sh
}

src_compile() {
	tc-export BUILD_CC

	# From version 5.3, ncurses also build c++ bindings, and as
	# we do not have a c++ compiler during bootstrap, disable
	# building it.  We will rebuild ncurses after gcc's second
	# build in bootstrap.sh.
	local myconf=""
	( use build || use bootstrap || use nocxx ) \
		&& myconf="${myconf} --without-cxx --without-cxx-binding --without-ada"

	# First we build the regular ncurses ...
	mkdir "${WORKDIR}"/narrowc
	cd "${WORKDIR}"/narrowc
	do_compile ${myconf}

	# Then we build the UTF-8 version
	if use unicode ; then
		mkdir "${WORKDIR}"/widec
		cd "${WORKDIR}"/widec
		do_compile ${myconf} --enable-widec --includedir=${PREFIX}/usr/include/ncursesw
	fi
}
do_compile() {
	ECONF_SOURCE=${S}

	local mylibprefix=""
	[[ ${USERLAND} == "Darwin" ]] && mylibprefix="${PREFIX}/usr"

	# We need the basic terminfo files in /etc, bug #37026.  We will
	# add '--with-terminfo-dirs' and then populate /etc/terminfo in
	# src_install() ...
	# The chtype/mmask-t settings below are to retain ABI compat
	# with ncurses-5.4 so dont change em !
	econf \
		--libdir=${mylibprefix}/$(get_libdir) \
		--with-terminfo-dirs="${PREFIX}/etc/terminfo:${PREFIX}/usr/share/terminfo" \
		--disable-termcap \
		--with-shared \
		--with-rcs-ids \
		--without-ada \
		--enable-symlinks \
		--program-prefix="" \
		--with-chtype='long' \
		--with-mmask-t='long' \
		$(use_with debug) \
		$(use_with gpm) \
		"$@" \
		|| die "configure failed"

	# A little hack to fix parallel builds ... they break when
	# generating sources so if we generate the sources first (in
	# non-parallel), we can then build the rest of the package
	# in parallel.  This is not really a perf hit since the source
	# generation is quite small.  -vapier
	emake -j1 sources || die "make sources failed"
	emake || die "make failed"
}

src_install() {
	# install unicode version first so that the non-unicode
	# files overwrite the unicode versions
	if use unicode ; then
		cd "${WORKDIR}"/widec
		sed -i '2iexit 0' man/edit_man.sh
		make DESTDIR="${DEST}" install || die "make widec install failed"
	fi
	cd "${WORKDIR}"/narrowc
	make DESTDIR="${DEST}" install || die "make narrowc install failed"

	if [[ ${USERLAND} != "Darwin" ]] ; then
		# Move static and extraneous ncurses libraries out of /lib
		dodir /usr/$(get_libdir)
		cd "${D}"/$(get_libdir)
		mv lib{form,menu,panel}.so* *.a "${D}"/usr/$(get_libdir)/
		gen_usr_ldscript lib{,n}curses.so
		use unicode && gen_usr_ldscript lib{,n}cursesw.so
	fi

	# We need the basic terminfo files in /etc, bug #37026
	einfo "Installing basic terminfo files in /etc..."
	for x in ansi console dumb linux rxvt screen sun vt{52,100,102,200,220} \
	         xterm xterm-color xterm-xfree86
	do
		local termfile=$(find "${D}"/usr/share/terminfo/ -name "${x}" 2>/dev/null)
		local basedir=$(basename $(dirname "${termfile}"))

		if [[ -n ${termfile} ]] ; then
			dodir /etc/terminfo/${basedir}
			mv ${termfile} "${D}"/etc/terminfo/${basedir}/
			dosym ../../../../etc/terminfo/${basedir}/${x} \
				/usr/share/terminfo/${basedir}/${x}
		fi
	done

	# Build fails to create this ...
	dosym ../share/terminfo /usr/$(get_libdir)/terminfo

	echo "CONFIG_PROTECT_MASK=\"/etc/terminfo\"" > "${T}"/50ncurses
	doenvd "${T}"/50ncurses

	if use build ; then
		cd "${D}"
		rm -rf usr/share/man
		cd usr/share/terminfo
		cp -pPR l/linux n/nxterm v/vt100 "${T}"
		rm -rf *
		mkdir l x v
		cp -pPR "${T}"/linux l
		cp -pPR "${T}"/nxterm x/xterm
		cp -pPR "${T}"/vt100 v
	else
		# Install xterm-debian terminfo entry to satisfy bug #18486
		LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${D}/usr/$(get_libdir):${D}/$(get_libdir) \
		TERMINFO=${D}/usr/share/terminfo \
			"${D}"/usr/bin/tic "${FILESDIR}"/xterm-debian.ti

		if use minimal ; then
			cp "${D}"/usr/share/terminfo/x/xterm-debian "${D}"/etc/terminfo/x/
			rm -r "${D}"/usr/share/terminfo
		fi

		cd "${S}"
		dodoc ANNOUNCE MANIFEST NEWS README* TO-DO doc/*.doc
		use doc && dohtml -r doc/html/
	fi
}

pkg_preinst() {
	if [[ ! -f ${ROOT}/etc/env.d/50ncurses ]] ; then
		mkdir -p "${ROOT}"/etc/env.d
		echo "CONFIG_PROTECT_MASK=\"/etc/terminfo\"" > \
			"${ROOT}"/etc/env.d/50ncurses
	fi
}

pkg_postinst() {
	# Old ncurses may still be around from old build tbz2's.
	rm -f "${ROOT}"/lib/libncurses.so.5.[23] "${ROOT}"/usr/lib/lib{form,menu,panel}.so.5.[23]
	if [[ $(get_libdir) != "lib" ]] ; then
		rm -f "${ROOT}"/$(get_libdir)/libncurses.so.5.[23] \
			"${ROOT}"/usr/$(get_libdir)/lib{form,menu,panel}.so.5.[23]
	fi
}
