# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit flag-o-matic toolchain-funcs

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="git://sourceware.org/git/newlib-cygwin.git"
	inherit git-r3
else
	SRC_URI="ftp://sourceware.org/pub/newlib/${P}.tar.gz"
	if [[ ${PV} != *.201[5-9]???? ]] ; then
		KEYWORDS="-* ~arm ~hppa ~m68k ~mips ~ppc ~ppc64 ~sparc ~x86 ~x64-cygwin"
	fi
fi

export CBUILD=${CBUILD:-${CHOST}}
export CTARGET=${CTARGET:-${CHOST}}
if [[ ${CTARGET} == ${CHOST} ]] ; then
	if [[ ${CATEGORY} == cross-* ]] ; then
		export CTARGET=${CATEGORY#cross-}
	fi
fi

DESCRIPTION="Newlib is a C library intended for use on embedded systems"
HOMEPAGE="https://sourceware.org/newlib/"

LICENSE="NEWLIB LIBGLOSS GPL-2"
SLOT="0"
IUSE="nls threads unicode crosscompile_opts_headers-only"
RESTRICT="strip"

NEWLIBBUILD="${WORKDIR}/build"

pkg_setup() {
	# Reject newlib-on-glibc type installs
	if [[ ${CTARGET} == ${CHOST} ]] ; then
		case ${CHOST} in
			*-newlib|*-elf|*-cygwin*) ;;
			*) die "Use sys-devel/crossdev to build a newlib toolchain" ;;
		esac
	fi
}

src_prepare() {
	default
	if [[ ${CHOST} == *-cygwin* ]] ; then
		local pvgr="${PV}-gentoo-${PR}"
		pvgr=${pvgr%-r0}
		einfo "Branding Gentoo/Cygwin ${pvgr} ..."
		sed -i -e "/Cygwin dll release/a\
			  __small_sprintf (name->release, \"%s\", \"${pvgr}\") ||
		  " winsup/cygwin/uname.cc || die
		eend $?
	fi
}

src_configure() {
	# we should fix this ...
	unset LDFLAGS
	CHOST=${CTARGET:-${CHOST}} strip-unsupported-flags

	local myconf=(
		# Disable legacy syscall stub code in newlib.  These have been
		# moved to libgloss for a long time now, so the code in newlib
		# itself just gets in the way.
		--disable-newlib-supplied-syscalls
	)
	[[ ${CTARGET} == "spu" ]] \
		&& myconf+=( --disable-newlib-multithread ) \
		|| myconf+=( $(use_enable threads newlib-multithread) )

	mkdir -p "${NEWLIBBUILD}"
	cd "${NEWLIBBUILD}"

	ECONF_SOURCE=${S} \
	econf \
		$(use_enable unicode newlib-mb) \
		$(use_enable nls) \
		"${myconf[@]}"
}

src_compile() {
	emake -C "${NEWLIBBUILD}"
}

src_install() {
	cd "${NEWLIBBUILD}"
	emake -j1 DESTDIR="${D}" install
#	env -uRESTRICT CHOST=${CTARGET} prepallstrip
	# minor hack to keep things clean
	rm -fR "${D}"/usr/share/info
	rm -fR "${D}"/usr/info
}
