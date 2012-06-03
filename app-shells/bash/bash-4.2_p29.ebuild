# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/bash/bash-4.2_p29.ebuild,v 1.1 2012/05/30 16:06:34 vapier Exp $

EAPI="1"

inherit eutils flag-o-matic toolchain-funcs multilib prefix

# Official patchlevel
# See ftp://ftp.cwru.edu/pub/bash/bash-4.2-patches/
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
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="afs bashlogger examples mem-scramble +net nls plugins +readline vanilla"

DEPEND=">=sys-libs/ncurses-5.2-r2
	readline? ( >=sys-libs/readline-6.2 )
	nls? ( virtual/libintl )"
RDEPEND="${DEPEND}
	!<sys-apps/portage-2.1.6.7_p1
	!<sys-apps/paludis-0.26.0_alpha5"
# we only need yacc when the .y files get patched (bash42-005)
DEPEND+=" virtual/yacc"

S=${WORKDIR}/${MY_P}

pkg_setup() {
	if is-flag -malign-double ; then #7332
		eerror "Detected bad CFLAGS '-malign-double'.  Do not use this"
		eerror "as it breaks LFS (struct stat64) on x86."
		die "remove -malign-double from your CFLAGS mr ricer"
	fi
	if use bashlogger ; then
		ewarn "The logging patch should ONLY be used in restricted (i.e. honeypot) envs."
		ewarn "This will log ALL output you enter into the shell, you have been warned."
	fi
}

src_unpack() {
	unpack ${MY_P}.tar.gz
	cd "${S}"

	# Include official patches
	[[ ${PLEVEL} -gt 0 ]] && epatch $(patches -s)

	# Clean out local libs so we know we use system ones
	rm -rf lib/{readline,termcap}/*
	touch lib/{readline,termcap}/Makefile.in # for config.status
	sed -ri -e 's:\$[(](RL|HIST)_LIBSRC[)]/[[:alpha:]]*.h::g' Makefile.in || die

	# Avoid regenerating docs after patches #407985
	sed -i -r '/^(HS|RL)USER/s:=.*:=:' doc/Makefile.in || die
	touch -r . doc/*

	epatch "${FILESDIR}"/${PN}-4.2-execute-job-control.patch #383237
	epatch "${FILESDIR}"/${PN}-4.2-parallel-build.patch
	epatch "${FILESDIR}"/${PN}-4.2-no-readline.patch

	# this adds additional prefixes
	epatch "${FILESDIR}"/${PN}-4.0-configs-prefix.patch
	eprefixify pathnames.h.in

	epatch "${FILESDIR}"/${PN}-4.0-bashintl-in-siglist.patch
	epatch "${FILESDIR}"/${PN}-4.0-cflags_for_build.patch

	if [[ ${CHOST} == *-interix* ]]; then
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
			-DSSH_SOURCE_BASHRC \
			$(use bashlogger && echo -DSYSLOG_HISTORY)
	else
	append-cppflags \
		-DDEFAULT_PATH_VALUE=\'\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"\' \
		-DSTANDARD_UTILS_PATH=\'\"/bin:/usr/bin:/sbin:/usr/sbin\"\' \
		-DSYS_BASHRC=\'\"/etc/bash/bashrc\"\' \
		-DSYS_BASH_LOGOUT=\'\"/etc/bash/bash_logout\"\' \
		-DNON_INTERACTIVE_LOGIN_SHELLS \
		-DSSH_SOURCE_BASHRC \
		$(use bashlogger && echo -DSYSLOG_HISTORY)
	fi

	# IRIX's MIPSpro produces garbage with >= -O2, bug #209137
	[[ ${CHOST} == mips-sgi-irix* ]] && replace-flags -O? -O1

	if [[ ${CHOST} == *-aix* ]] || [[ ${CHOST} == *-hpux* ]] ; then
		# Avoid finding tgetent() in anything else but ncurses library,
		# as <termcap.h> is provided by ncurses, even during bootstrap
		# on AIX and HP-UX, and we would get undefined symbols like
		# BC, PC, UP if linking against something else.
		# The bash-bug is that it doesn't check for <termcap.h> provider,
		# and unfortunately {,n}curses is checked last.
		# Even if ncurses provides libcurses.so->libncurses.so symlink,
		# it feels more clean to link against libncurses.so directly.
		# (all configure-variables for tgetent() are shown here)
		export ac_cv_func_tgetent=no
		export ac_cv_lib_termcap_tgetent=no # found on HP-UX
		export ac_cv_lib_tinfo_tgetent=no
		export ac_cv_lib_curses_tgetent=no # found on AIX
		#export ac_cv_lib_ncurses_tgetent=no
	fi

	# Don't even think about building this statically without
	# reading Bug 7714 first.  If you still build it statically,
	# don't come crying to us with bugs ;).
	#use static && export LDFLAGS="${LDFLAGS} -static"
	use nls || myconf="${myconf} --disable-nls"

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

	use plugins && case ${CHOST} in
		*-linux-gnu | *-solaris* | *-freebsd* )
			append-ldflags -Wl,-rpath,"${EPREFIX}"/usr/$(get_libdir)/bash
		;;
		# Darwin doesn't need an rpath here (in fact doesn't grok the argument)
	esac

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
		${myconf}
	emake || die

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
		local tmp=$(emktemp "${EROOT}"/bin)
		ln -sf "${target}" "${tmp}"
		mv -f "${tmp}" "${EROOT}"/bin/sh
	fi
}

pkg_postinst() {
	# If /bin/sh does not exist, provide it
	if [[ ! -e ${EROOT}/bin/sh ]]; then
		ln -sf bash "${EROOT}"/bin/sh
	fi
}
