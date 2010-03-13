# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/readline/readline-6.1.ebuild,v 1.2 2010/03/12 18:14:16 ssuominen Exp $

inherit autotools eutils multilib toolchain-funcs flag-o-matic

# Official patches
# See ftp://ftp.cwru.edu/pub/bash/readline-6.0-patches/
PLEVEL=${PV##*_p}
MY_PV=${PV/_p*}
MY_PV=${MY_PV/_/-}
MY_P=${PN}-${MY_PV}
[[ ${PV} != *_p* ]] && PLEVEL=0
patches() {
	[[ ${PLEVEL} -eq 0 ]] && return 1
	local opt=$1
	eval set -- {1..${PLEVEL}}
	set -- $(printf "${PN}${MY_PV/\.}-%03d " "$@")
	if [[ ${opt} == -s ]] ; then
		echo "${@/#/${DISTDIR}/}"
	else
		local u
		for u in ftp://ftp.cwru.edu/pub/bash mirror://gnu/${PN} ; do
			printf "${u}/${PN}-${MY_PV}-patches/%s " "$@"
		done
	fi
}

DESCRIPTION="Another cute console display library"
HOMEPAGE="http://cnswww.cns.cwru.edu/php/chet/readline/rltop.html"
SRC_URI="mirror://gnu/${PN}/${MY_P}.tar.gz $(patches)"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

# We must be certain that we have a bash that is linked
# to its internal readline, else we may get problems.
RDEPEND=">=sys-libs/ncurses-5.2-r2"
DEPEND="${RDEPEND}
	>=app-shells/bash-2.05b-r2"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${MY_P}.tar.gz

	cd "${S}"
	[[ ${PLEVEL} -gt 0 ]] && epatch $(patches -s)

	epatch "${FILESDIR}"/${PN}-5.0-no_rpath.patch
	epatch "${FILESDIR}"/${PN}-5.2-no-ignore-shlib-errors.patch #216952

	epatch "${FILESDIR}"/${PN}-5.1-rlfe-extern.patch
	epatch "${FILESDIR}"/${PN}-5.2-rlfe-aix-eff_uid.patch
	epatch "${FILESDIR}"/${PN}-5.2-rlfe-hpux.patch
	epatch "${FILESDIR}"/${PN}-6.0-rlfe-solaris.patch
	epatch "${FILESDIR}"/${PN}-5.2-interix.patch
	epatch "${FILESDIR}"/${PN}-5.2-ia64hpux.patch
	epatch "${FILESDIR}"/${PN}-6.0-mint.patch
	epatch "${FILESDIR}"/${PN}-6.1-mint.patch
	epatch "${FILESDIR}"/${PN}-6.1-darwin-shlib-versioning.patch
	epatch "${FILESDIR}"/${PN}-6.1-freebsd.patch
	epatch "${FILESDIR}"/${PN}-6.1-aix-expfull.patch

	# force ncurses linking #71420
	sed -i -e 's:^SHLIB_LIBS=:SHLIB_LIBS=-lncurses:' support/shobj-conf || die "sed"

	# fix building under Gentoo/FreeBSD; upstream FreeBSD deprecated
	# objformat for years, so we don't want to rely on that.
	sed -i -e '/objformat/s:if .*; then:if true; then:' support/shobj-conf || die

	ln -s ../.. examples/rlfe/readline # for local readline headers
}

src_compile() {
	append-cppflags -D_GNU_SOURCE

	econf --with-curses || die
	emake || die

	if ! tc-is-cross-compiler ; then
		# linkable symlinks are created during 'make install' only (on AIX)
		[[ ${CHOST} != *-aix* ]] ||
		emake DESTDIR="${S}/examples/rlfe" libdir=/ install || die
		# code is full of AC_TRY_RUN()
		cd examples/rlfe
		append-ldflags -L.
		local l
		[[ ${CHOST} == *-aix* ]] ||
		for l in readline history ; do
			ln -s ../../shlib/lib${l}*$(get_libname)* lib${l}$(get_libname)
			ln -sf ../../lib${l}.a lib${l}.a
		done
		econf || die
		emake || die
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die
	gen_usr_ldscript -a readline history #4411

	if ! tc-is-cross-compiler; then
		dobin examples/rlfe/rlfe || die
	fi

	dodoc CHANGELOG CHANGES README USAGE NEWS
	docinto ps
	dodoc doc/*.ps
	dohtml -r doc
}

pkg_preinst() {
	preserve_old_lib /$(get_libdir)/lib{history,readline}$(get_libname 4) #29865
	preserve_old_lib /$(get_libdir)/lib{history,readline}$(get_libname 5) #29865
}

pkg_postinst() {
	preserve_old_lib_notify /$(get_libdir)/lib{history,readline}$(get_libname 4)
	preserve_old_lib_notify /$(get_libdir)/lib{history,readline}$(get_libname 5)
}
