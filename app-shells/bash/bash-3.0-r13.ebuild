# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/bash/bash-3.0-r13.ebuild,v 1.2 2005/10/20 16:51:39 flameeyes Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs

# Official patchlevel
# See ftp://ftp.cwru.edu/pub/bash/bash-3.0-patches/
PLEVEL=16

DESCRIPTION="The standard GNU Bourne again shell"
HOMEPAGE="http://cnswww.cns.cwru.edu/~chet/bash/bashtop.html"
# Hit the GNU mirrors before hitting Chet's site
SRC_URI="mirror://gnu/bash/${P}.tar.gz
	ftp://ftp.cwru.edu/pub/bash/${P}.tar.gz
	$(for ((i=1; i<=PLEVEL; i++)); do
		printf 'ftp://ftp.cwru.edu/pub/bash/bash-%s-patches/bash%s-%03d\n' \
			${PV} ${PV/\.} ${i}
		printf 'mirror://gnu/bash/bash-%s-patches/bash%s-%03d\n' \
			${PV} ${PV/\.} ${i}
	done)"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc-macos ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="afs nls build bashlogger unicode"

# we link statically with ncurses
DEPEND=">=sys-libs/ncurses-5.2-r2"
RDEPEND=""

src_unpack() {
	unpack ${P}.tar.gz
	cd ${S}
	epatch "${FILESDIR}"/${P}-gentoo.patch

	# Remove autoconf dependency
	sed -i -e "/&& autoconf/d" Makefile.in

	# Include official patches
	local i
	for ((i=1; i<=PLEVEL; i++)); do
		epatch "${DISTDIR}"/${PN}${PV/\.}-$(printf '%03d' ${i})
	done

	# Fall back to /etc/inputrc
	epatch "${FILESDIR}"/${P}-etc-inputrc.patch
	# Fix network tests on Darwin #79124
	epatch "${FILESDIR}"/${P}-darwin-conn.patch
	# read patch headers for more info ... many ripped from Fedora/Debian/SuSe
	for i in afs crash jobs manpage pwd read-e-segfault ulimit histtimeformat \
	         locale multibyteifs rl-display rl-self-insert
	do
		epatch "${FILESDIR}"/${P}-${i}.patch
	done
	# Hacks for bugs in unicode support #69407 #108936
	if use unicode ; then
		epatch "${FILESDIR}"/${P}-prompt.patch
		epatch "${FILESDIR}"/${P}-utf8.patch
	fi
	# Fix read-builtin and the -u pipe option #87093
	epatch "${FILESDIR}"/${P}-read-builtin-pipe.patch
	# Don't barf on handled signals in scripts
	epatch "${FILESDIR}"/${P}-trap-fg-signals.patch
	# Fix a problem when using pipes and PGRP_PIPE #92349
	epatch "${FILESDIR}"/${P}-pgrp-pipe-fix.patch
	# Make sure static linking always works #100138
	epatch "${FILESDIR}"/${P}-force-static-linking.patch
	# Fix parallel builds #87247
	epatch "${FILESDIR}"/${P}-parallel.patch
	# Log bash commands to syslog #91327
	if use bashlogger ; then
		echo
		ewarn "The logging patch should ONLY be used in restricted (i.e. honeypot) envs."
		ewarn "This will log ALL output you enter into the shell, you have been warned."
		ebeep
		epause
		epatch "${FILESDIR}"/${P}-bash-logger.patch
	fi

	epatch "${FILESDIR}"/${P}-configs.patch

	# Add strnlen function for non-glibc systems, as one of Fedora's patches
	# requires it.
	epatch "${FILESDIR}"/${P}-strnlen.patch

	epatch "${FILESDIR}"/${P}-pathnames.patch

	sed -i 's:-lcurses:-lncurses:' configure || die "sed configure"

	sed -i -e "s:\@PREFIX\@:${PREFIX}:g" config-top.h pathnames.h.in \
		|| die "sed failed."
}

src_compile() {
	filter-flags -malign-double

	local myconf=

	# Always use the buildin readline, else if we update readline
	# bash gets borked as readline is usually not binary compadible
	# between minor versions.
	#
	# Martin Schlemmer <azarah@gentoo.org> (1 Sep 2002)
	#use readline && myconf="--with-installed-readline"

	# Don't even think about building this statically without
	# reading Bug 7714 first.  If you still build it statically,
	# don't come crying to use with bugs ;).
	#use static && export LDFLAGS="${LDFLAGS} -static"
	use nls || myconf="${myconf} --disable-nls"

	echo 'int main(){}' > "${T}"/term-test.c
	if ! $(tc-getCC) -static -lncurses "${T}"/term-test.c 2> /dev/null ; then
		export bash_cv_termcap_lib=gnutermcap
	else
		export bash_cv_termcap_lib=libcurses
		myconf="${myconf} --with-ncurses"
	fi

	econf \
		$(use_with afs) \
		--disable-profiling \
		--without-gnu-malloc \
		${myconf} || die
	# Make sure we always link statically with ncurses
	sed -i "/^TERMCAP_LIB/s:-lncurses:-Wl,-Bstatic -lncurses -Wl,-Bdynamic:" Makefile || die "sed failed"
	emake -j1 || die "make failed"  # see bug 102426
}

src_install() {
	einstall || die

	dodir /bin
	mv "${D}"/usr/bin/bash "${D}"/bin/
	[[ ${USERLAND} != "BSD" ]] && dosym bash /bin/sh
	dosym bash /bin/rbash

	insinto /etc/bash
	doins "${FILESDIR}"/{bashrc,bash_logout}
	insinto /etc/skel
	for f in bash{_logout,_profile,rc} ; do
		newins "${FILESDIR}"/dot-${f} .${f}
	done

	if use build ; then
		rm -rf "${D}"/usr
	else
		doman doc/*.1
		dodoc README NEWS AUTHORS CHANGES COMPAT Y2K doc/FAQ doc/INTRO
		dosym bash.info.gz /usr/share/info/bashref.info.gz
	fi
}

pkg_preinst() {
	if [[ -e ${ROOT}/etc/bashrc ]] && [[ ! -d ${ROOT}/etc/bash ]] ; then
		mkdir -p "${ROOT}"/etc/bash
		mv -f "${ROOT}"/etc/bashrc "${ROOT}"/etc/bash/
	fi

	# our bash_logout is just a place holder so dont 
	# force users to go through etc-update all the time
	if [[ -e ${ROOT}/etc/bash/bash_logout ]] ; then
		rm -f "${D}"/etc/bash/bash_logout
	fi
}
