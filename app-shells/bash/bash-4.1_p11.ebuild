# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/bash/bash-4.1_p11.ebuild,v 1.7 2014/01/18 02:25:19 vapier Exp $

EAPI="4"

inherit eutils flag-o-matic toolchain-funcs multilib prefix

# Official patchlevel
# See ftp://ftp.cwru.edu/pub/bash/bash-4.1-patches/
PLEVEL=${PV##*_p}
MY_PV=${PV/_p*}
MY_PV=${MY_PV/_/-}
MY_P=${PN}-${MY_PV}
[[ ${PV} != *_p* ]] && PLEVEL=0
patches() {
	local opt=$1 plevel=${2:-${PLEVEL}} pn=${3:-${PN}} pv=${4:-${MY_PV}}
	[[ ${plevel} -eq 0 ]] && return 1
	eval set -- {1..${plevel}}
	set -- $(printf "${pn}${pv/\.}-%03d " "$@")
	if [[ ${opt} == -s ]] ; then
		echo "${@/#/${DISTDIR}/}"
	else
		local u
		for u in ftp://ftp.cwru.edu/pub/bash mirror://gnu/${pn} ; do
			printf "${u}/${pn}-${pv}-patches/%s " "$@"
		done
	fi
}

DESCRIPTION="The standard GNU Bourne again shell"
HOMEPAGE="http://tiswww.case.edu/php/chet/bash/bashtop.html"
SRC_URI="mirror://gnu/bash/${MY_P}.tar.gz $(patches)"

LICENSE="GPL-3"
SLOT="${MY_PV}"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

IUSE="afs mem-scramble +net nls +readline"

DEPEND=">=sys-libs/ncurses-5.2-r2
	readline? ( >=sys-libs/readline-6.2 )
	nls? ( virtual/libintl )"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_P}

pkg_setup() {
	if is-flag -malign-double ; then #7332
		eerror "Detected bad CFLAGS '-malign-double'.  Do not use this"
		eerror "as it breaks LFS (struct stat64) on x86."
		die "remove -malign-double from your CFLAGS mr ricer"
	fi
}

src_unpack() {
	unpack ${MY_P}.tar.gz
}

src_prepare() {
	# Include official patches
	[[ ${PLEVEL} -gt 0 ]] && epatch $(patches -s)

	# Clean out local libs so we know we use system ones
	rm -rf lib/{readline,termcap}/*
	touch lib/{readline,termcap}/Makefile.in # for config.status
	sed -ri -e 's:\$[(](RL|HIST)_LIBSRC[)]/[[:alpha:]]*.h::g' Makefile.in || die

	epatch "${FILESDIR}"/${PN}-4.1-fbsd-eaccess.patch #303411
	sed -i '1i#define NEED_FPURGE_DECL' execute_cmd.c # needs fpurge() decl
	epatch "${FILESDIR}"/${PN}-4.1-parallel-build.patch
	epatch "${FILESDIR}"/${PN}-4.1-blocking-namedpipe.patch # aix lacks /dev/fd/

	# this adds additional prefixes
	epatch "${FILESDIR}"/${PN}-4.0-configs-prefix.patch
	eprefixify pathnames.h.in

	epatch "${FILESDIR}"/${PN}-3.2-getcwd-interix.patch
	epatch "${FILESDIR}"/${PN}-4.0-bashintl-in-siglist.patch
	epatch "${FILESDIR}"/${PN}-4.0-cflags_for_build.patch
	epatch "${FILESDIR}"/${PN}-4.0-childmax-pids.patch # AIX, Interix

	if [[ ${CHOST} == *-interix* ]]; then
		epatch "${FILESDIR}"/${PN}-4.1-interix-stdint.patch
		epatch "${FILESDIR}"/${PN}-4.0-interix.patch
		epatch "${FILESDIR}"/${PN}-4.1-interix-access-suacomp.patch
		epatch "${FILESDIR}"/${PN}-4.0-interix-x64.patch
	fi

	# Nasty trick to set bashbug's shebang to bash instead of sh. We don't have
	# sh while bootstrapping for the first time, This works around bug 309825
	sed -i -e '1s:sh:bash:' support/bashbug.sh || die

	# modify the bashrc file for prefix
	cp "${FILESDIR}"/bashrc "${T}"
	cd "${T}"
	epatch "${FILESDIR}"/bashrc-prefix.patch
	eprefixify "${T}"/bashrc

	# DON'T YOU EVER PUT eautoreconf OR SIMILAR HERE!  THIS IS A CRITICAL
	# PACKAGE THAT MUST NOT RELY ON AUTOTOOLS, USE A SELF-SUFFICIENT PATCH
	# INSTEAD!!!

	epatch_user
}

src_configure() {
	local myconf=()

	myconf+=( --without-lispdir ) #335896

	# For descriptions of these, see config-top.h
	# bashrc/#26952 bash_logout/#90488 ssh/#24762
	if use prefix ; then
		append-cppflags \
			-DDEFAULT_PATH_VALUE=\'\"${EPREFIX}/usr/sbin:${EPREFIX}/usr/bin:${EPREFIX}/sbin:${EPREFIX}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"\' \
			-DSTANDARD_UTILS_PATH=\'\"${EPREFIX}/bin:${EPREFIX}/usr/bin:${EPREFIX}/sbin:${EPREFIX}/usr/sbin:/bin:/usr/bin:/sbin:/usr/sbin\"\' \
			-DSYS_BASHRC=\'\"${EPREFIX}/etc/bash/bashrc\"\' \
			-DSYS_BASH_LOGOUT=\'\"${EPREFIX}/etc/bash/bash_logout\"\' \
			-DNON_INTERACTIVE_LOGIN_SHELLS \
			-DSSH_SOURCE_BASHRC
	else
	append-cppflags \
		-DDEFAULT_PATH_VALUE=\'\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"\' \
		-DSTANDARD_UTILS_PATH=\'\"/bin:/usr/bin:/sbin:/usr/sbin\"\' \
		-DSYS_BASHRC=\'\"/etc/bash/bashrc\"\' \
		-DSYS_BASH_LOGOUT=\'\"/etc/bash/bash_logout\"\' \
		-DNON_INTERACTIVE_LOGIN_SHELLS \
		-DSSH_SOURCE_BASHRC
	fi

	# IRIX's MIPSpro produces garbage with >= -O2, bug #209137
	[[ ${CHOST} == mips-sgi-irix* ]] && replace-flags -O? -O1

	# Don't even think about building this statically without
	# reading Bug 7714 first.  If you still build it statically,
	# don't come crying to us with bugs ;).
	#use static && export LDFLAGS="${LDFLAGS} -static"
	use nls || myconf+=( --disable-nls )

	# Historically, we always used the builtin readline, but since
	# our handling of SONAME upgrades has gotten much more stable
	# in the PM (and the readline ebuild itself preserves the old
	# libs during upgrades), linking against the system copy should
	# be safe.
	# Exact cached version here doesn't really matter as long as it
	# is at least what's in the DEPEND up above.
	export ac_cv_rl_version=6.2

	# Force linking with system curses ... the bundled termcap lib
	# sucks bad compared to ncurses.  For the most part, ncurses
	# is here because readline needs it.  But bash itself calls
	# ncurses in one or two small places :(.

	if [[ ${CHOST} == *-interix* ]]; then
		export ac_cv_header_inttypes_h=no
		export gt_cv_header_inttypes_h=no
		export jm_ac_cv_header_inttypes_h=no

		# argh... something doomed this test on windows ... ???
		export bash_cv_type_intmax_t=yes
		export bash_cv_type_uintmax_t=yes
	fi

	tc-export AR #444070
	econf \
		--with-installed-readline=. \
		--with-curses \
		$(use_with afs) \
		$(use_enable net net-redirections) \
		--disable-profiling \
		$(use_enable mem-scramble) \
		$(use_with mem-scramble bash-malloc) \
		$(use_enable readline) \
		$(use_enable readline history) \
		$(use_enable readline bang-history) \
		"${myconf[@]}"
}

src_install() {
	into /
	newbin bash bash-${SLOT}

	newman doc/bash.1 bash-${SLOT}.1
	newman doc/builtins.1 builtins-${SLOT}.1

	insinto /usr/share/info
	newins doc/bashref.info bash-${SLOT}.info
	dosym bash-${SLOT}.info /usr/share/info/bashref-${SLOT}.info

 	dodoc README NEWS AUTHORS CHANGES COMPAT Y2K doc/FAQ doc/INTRO
}
