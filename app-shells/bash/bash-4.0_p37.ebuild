# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/bash/bash-4.0_p37.ebuild,v 1.2 2010/03/06 22:52:36 vapier Exp $

EAPI="1"

inherit eutils flag-o-matic toolchain-funcs multilib prefix

# Official patchlevel
# See ftp://ftp.cwru.edu/pub/bash/bash-3.2-patches/
PLEVEL=${PV##*_p}
MY_PV=${PV/_p*}
MY_P=${PN}-${MY_PV}
[[ ${PV} != *_p* ]] && PLEVEL=0
READLINE_VER=6.0
READLINE_PLEVEL=0 # both readline patches are also released as bash patches
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
SRC_URI="mirror://gnu/bash/${MY_P}.tar.gz $(patches)
	$(patches ${READLINE_PLEVEL} readline ${READLINE_VER})"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="afs bashlogger examples i6fork +net nls plugins vanilla"

DEPEND=">=sys-libs/ncurses-5.2-r2
	nls? ( virtual/libintl )"
RDEPEND="${DEPEND}
	!<sys-apps/portage-2.1.5
	!<sys-apps/paludis-0.26.0_alpha5
	i6fork? ( sys-libs/i6fork )"

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
	cd "${S}"

	# Include official patches
	[[ ${PLEVEL} -gt 0 ]] && epatch $(patches -s)
	cd lib/readline
	[[ ${READLINE_PLEVEL} -gt 0 ]] && epatch $(patches -s ${READLINE_PLEVEL} readline ${READLINE_VER})
	cd ../..

	# bash40-037 touches configure.in :x
	epatch "${FILESDIR}"/${PN}-4.0-configure.patch #304901

	if ! use vanilla ; then
		sed -i '1i#define NEED_FPURGE_DECL' execute_cmd.c # needs fpurge() decl
		epatch "${FILESDIR}"/${PN}-3.2-parallel-build.patch #189671
		epatch "${FILESDIR}"/${PN}-4.0-ldflags-for-build.patch #211947
		epatch "${FILESDIR}"/${PN}-4.0-negative-return.patch
		epatch "${FILESDIR}"/${PN}-4.0-parallel-build.patch #267613
		# Log bash commands to syslog #91327
		if use bashlogger ; then
			ewarn "The logging patch should ONLY be used in restricted (i.e. honeypot) envs."
			ewarn "This will log ALL output you enter into the shell, you have been warned."
			ebeep
			epause
			epatch "${FILESDIR}"/${PN}-3.1-bash-logger.patch
		fi
		sed -i '/\.o: .*shell\.h/s:$: pathnames.h:' Makefile.in #267613
	fi

	# this adds additional prefixes
	epatch "${FILESDIR}"/${PN}-4.0-configs-prefix.patch
	eprefixify pathnames.h.in

	epatch "${FILESDIR}"/${PN}-3.2-getcwd-interix.patch
	epatch "${FILESDIR}"/${PN}-4.0-mint.patch
	epatch "${FILESDIR}"/${PN}-4.0-bashintl-in-siglist.patch
	epatch "${FILESDIR}"/${PN}-4.0-cflags_for_build.patch

	if [[ ${CHOST} == *-interix* ]]; then
		epatch "${FILESDIR}"/${PN}-3.2-interix-stdint.patch
		epatch "${FILESDIR}"/${PN}-4.0-interix.patch
		epatch "${FILESDIR}"/${PN}-4.0-interix-access.patch
		epatch "${FILESDIR}"/${PN}-4.0-interix-x64.patch
	fi

	# modify the bashrc file for prefix
	cp "${FILESDIR}"/bashrc "${T}"
	cd "${T}"
	epatch "${FILESDIR}"/bashrc-prefix.patch
	eprefixify "${T}"/bashrc

	# DON'T YOU EVER PUT eautoreconf OR SIMILAR HERE!  THIS IS A CRITICAL
	# PACKAGE THAT MUST NOT RELY ON AUTOTOOLS, USE A SELF-SUFFICIENT PATCH
	# INSTEAD!!!
}

src_compile() {
	local myconf=

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

	# Always use the buildin readline, else if we update readline
	# bash gets borked as readline is usually not binary compadible
	# between minor versions.
	#myconf="${myconf} $(use_with !readline installed-readline)"
	myconf="${myconf} --without-installed-readline"

	# Don't even think about building this statically without
	# reading Bug 7714 first.  If you still build it statically,
	# don't come crying to us with bugs ;).
	#use static && export LDFLAGS="${LDFLAGS} -static"
	use nls || myconf="${myconf} --disable-nls"

	# Force linking with system curses ... the bundled termcap lib
	# sucks bad compared to ncurses
	myconf="${myconf} --with-curses"

	use plugins && case ${CHOST} in
		*-linux-gnu | *-solaris* | *-freebsd* )
			append-ldflags -Wl,-rpath,"${EPREFIX}"/usr/$(get_libdir)/bash
		;;
		# Darwin doesn't need an rpath here
	esac

	if [[ ${CHOST} == *-interix* ]]; then
		export ac_cv_header_inttypes_h=no
		export gt_cv_header_inttypes_h=no
		export jm_ac_cv_header_inttypes_h=no

		# argh... something doomed this test on windows ... ???
		export bash_cv_type_intmax_t=yes
		export bash_cv_type_uintmax_t=yes
	fi

	if use i6fork; then
		append-libs -li6fork
	fi

	econf \
		$(use_with afs) \
		$(use_enable net net-redirections) \
		--disable-profiling \
		$(use_enable mem-scramble) \
		$(use_with mem-scramble bash-malloc) \
		${myconf} || die
	emake || die "make failed"

	if use plugins ; then
		emake -C examples/loadables all others || die
	fi
}

src_install() {
	emake install DESTDIR="${D}" || die

	dodir /bin
	mv "${ED}"/usr/bin/bash "${ED}"/bin/ || die
	dosym bash /bin/rbash

	insinto /etc/bash
	doins "${T}"/bashrc
	doins "${FILESDIR}"/bash_logout
	insinto /etc/skel
	for f in bash{_logout,_profile,rc} ; do
		newins "${FILESDIR}"/dot-${f} .${f}
	done

	sed -i -e "s:#${USERLAND}#@::" "${ED}"/etc/skel/.bashrc "${ED}"/etc/bash/bashrc
	sed -i -e '/#@/d' "${ED}"/etc/skel/.bashrc "${ED}"/etc/bash/bashrc

	if use plugins ; then
		exeinto /usr/$(get_libdir)/bash
		doexe $(echo examples/loadables/*.o | sed 's:\.o::g') || die
	fi

	if use examples ; then
		for d in examples/{functions,misc,scripts,scripts.noah,scripts.v2} ; do
			exeinto /usr/share/doc/${PF}/${d}
			insinto /usr/share/doc/${PF}/${d}
			for f in ${d}/* ; do
				if [[ ${f##*/} != PERMISSION ]] && [[ ${f##*/} != *README ]] ; then
					doexe ${f}
				else
					doins ${f}
				fi
			done
		done
	fi

	doman doc/*.1
	dodoc README NEWS AUTHORS CHANGES COMPAT Y2K doc/FAQ doc/INTRO
	dosym bash.info /usr/share/info/bashref.info
}

pkg_preinst() {
	if [[ -e ${EROOT}/etc/bashrc ]] && [[ ! -d ${EROOT}/etc/bash ]] ; then
		mkdir -p "${EROOT}"/etc/bash
		mv -f "${EROOT}"/etc/bashrc "${EROOT}"/etc/bash/
	fi

	if [[ -L ${EROOT}/bin/sh ]]; then
		# rewrite the symlink to ensure that its mtime changes. having /bin/sh
		# missing even temporarily causes a fatal error with paludis.
		local target=$(readlink "${EROOT}"/bin/sh)
		ln -sf "${target}" "${EROOT}"/bin/sh
	fi
}

pkg_postinst() {
	# If /bin/sh does not exist, provide it
	if [[ ! -e ${EROOT}/bin/sh ]]; then
		ln -sf bash "${EROOT}"/bin/sh
	fi
}
