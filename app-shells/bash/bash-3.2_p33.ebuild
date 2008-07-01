# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/bash/bash-3.2_p33.ebuild,v 1.12 2008/06/01 12:18:46 vapier Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs multilib autotools

# Official patchlevel
# See ftp://ftp.cwru.edu/pub/bash/bash-3.2-patches/
PLEVEL=${PV##*_p}
MY_PV=${PV/_p*}
MY_P=${PN}-${MY_PV}
READLINE_VER=5.2
READLINE_PLEVEL=0 # both readline patches are also released as bash patches

DESCRIPTION="The standard GNU Bourne again shell"
HOMEPAGE="http://cnswww.cns.cwru.edu/~chet/bash/bashtop.html"
SRC_URI="mirror://gnu/bash/${MY_P}.tar.gz
	ftp://ftp.cwru.edu/pub/bash/${MY_P}.tar.gz
	$(for ((i=1; i<=PLEVEL; i++)); do
		printf 'ftp://ftp.cwru.edu/pub/bash/bash-%s-patches/bash%s-%03d\n' \
			${MY_PV} ${MY_PV/\.} ${i}
		printf 'mirror://gnu/bash/bash-%s-patches/bash%s-%03d\n' \
			${MY_PV} ${MY_PV/\.} ${i}
	done)
	$(for ((i=1; i<=READLINE_PLEVEL; i++)); do
		printf 'ftp://ftp.cwru.edu/pub/bash/readline-%s-patches/readline%s-%03d\n' \
			${READLINE_VER} ${READLINE_VER/\.} ${i}
		printf 'mirror://gnu/bash/readline-%s-patches/readline%s-%03d\n' \
			${READLINE_VER} ${READLINE_VER/\.} ${i}
	done)"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="afs bashlogger nls plugins vanilla"

DEPEND=">=sys-libs/ncurses-5.2-r2"
RDEPEND="${DEPEND}
	!<sys-apps/portage-2.1.4_rc1
	!<sys-apps/paludis-0.26.0_alpha5"

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
	local i
	for ((i=1; i<=PLEVEL; i++)); do
		epatch "${DISTDIR}"/${PN}${MY_PV/\.}-$(printf '%03d' ${i})
	done
	cd lib/readline
	for ((i=1; i<=READLINE_PLEVEL; i++)); do
		epatch "${DISTDIR}"/readline${READLINE_VER/\.}-$(printf '%03d' ${i})
	done
	cd ../..

	if ! use vanilla ; then
		epatch "${FILESDIR}"/${PN}-3.1-gentoo.patch
		epatch "${FILESDIR}"/${PN}-3.2-loadables.patch
		epatch "${FILESDIR}"/${PN}-3.2-parallel-build.patch #189671
		epatch "${FILESDIR}"/${PN}-3.2-ldflags-for-build.patch #211947

		# Fix process substitution on BSD.
		epatch "${FILESDIR}"/${PN}-3.2-process-subst.patch

		epatch "${FILESDIR}"/${PN}-3.2-ulimit.patch
		# Don't barf on handled signals in scripts
		epatch "${FILESDIR}"/${PN}-3.0-trap-fg-signals.patch
		epatch "${FILESDIR}"/${PN}-3.2-dev-fd-test-as-user.patch #131875
		# Log bash commands to syslog #91327
		if use bashlogger ; then
			echo
			ewarn "The logging patch should ONLY be used in restricted (i.e. honeypot) envs."
			ewarn "This will log ALL output you enter into the shell, you have been warned."
			ebeep
			epause
			epatch "${FILESDIR}"/${PN}-3.1-bash-logger.patch
		fi
	fi

	epatch "${FILESDIR}"/${PN}-3.0-configs.patch
	# this one makes the above one prefix paths + additional prefixes added
	epatch "${FILESDIR}"/${PN}-3.0-configs-prefix.patch
	eprefixify config-top.h pathnames.h.in

	epatch "${FILESDIR}"/${PN}-3.2-getcwd-memcpy.patch
	epatch "${FILESDIR}"/${PN}-3.2-getcwd-interix.patch

	# intmax_t and uintmax_t should be looked for in stdint.h on interix
	[[ ${CHOST} == *-interix* ]] && epatch "${FILESDIR}"/${PN}-3.2-interix-stdint.patch

	# modify the bashrc file for prefix
	cp "${FILESDIR}"/bashrc "${T}"
	cd "${T}"
	epatch "${FILESDIR}"/bashrc-prefix.patch
	eprefixify "${T}"/bashrc

	cd "${S}"
	eautoreconf
}

src_compile() {
	local myconf=

	# IRIX's MIPSpro produces garbage with >= -O2, bug #209137
	[[ ${CHOST} == mips-sgi-irix* ]] && replace-flags -O? -O1

	# Always use the buildin readline, else if we update readline
	# bash gets borked as readline is usually not binary compadible
	# between minor versions.
	#myconf="${myconf} $(use_with !readline installed-readline)"
	myconf="${myconf} --without-installed-readline"

	# Don't even think about building this statically without
	# reading Bug 7714 first.  If you still build it statically,
	# don't come crying to use with bugs ;).
	#use static && export LDFLAGS="${LDFLAGS} -static"
	use nls || myconf="${myconf} --disable-nls"

	# Force linking with system curses ... the bundled termcap lib
	# sucks bad compared to ncurses
	myconf="${myconf} --with-curses"

	# Default path is to use /usr/local/..... regardless.  This little
	# magic will set the default path to /usr/..... and keep us from
	# worrying about the rest of the path getting out of sync with the
	# ebuild code.
	eval $(echo export $(ac_default_prefix="${EPREFIX}/usr"; eval echo $(grep DEBUGGER_START_FILE= configure)))

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
	fi

	econf \
		$(use_with afs) \
		--disable-profiling \
		--without-gnu-malloc \
		${myconf} || die
	# avoid parallel make breaking
	emake -j1 -C lib/intl libintl.h || die "make libintl.h failed"
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
	doins "${FILESDIR}"/bash_logout
	doins "${T}"/bashrc
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

	doman doc/*.1
	dodoc README NEWS AUTHORS CHANGES COMPAT Y2K doc/FAQ doc/INTRO
	dosym bash.info /usr/share/info/bashref.info
}

pkg_preinst() {
	if [[ -e ${EROOT}/etc/bashrc ]] && [[ ! -d ${EROOT}/etc/bash ]] ; then
		mkdir -p "${EROOT}"/etc/bash
		mv -f "${EROOT}"/etc/bashrc "${EROOT}"/etc/bash/
	fi

	# our bash_logout is just a place holder so dont
	# force users to go through etc-update all the time
	if [[ -e ${EROOT}/etc/bash/bash_logout ]] ; then
		rm -f "${ED}"/etc/bash/bash_logout
	fi

	# If /bin/sh does not exist or is bash, then provide it
	# Otherwise leave it alone
	if [[ ! -e ${EROOT}/bin/sh ]] ; then
		ln -s bash "${EROOT}"/bin/sh
	elif [[ -L ${EROOT}/bin/sh ]] ; then
		case $(readlink "${EROOT}"/bin/sh) in
			bash|/bin/bash) cp -pPR "${EROOT}"/bin/sh "${ED}"/bin/ ;;
		esac
	fi
}
