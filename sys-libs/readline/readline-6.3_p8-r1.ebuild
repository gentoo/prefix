# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit eutils multilib toolchain-funcs flag-o-matic multilib-minimal libtool

# Official patches
# See ftp://ftp.cwru.edu/pub/bash/readline-6.3-patches/
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
HOSTLTV="0.1.0"
HOSTLT="host-libtool-${HOSTLTV}"
HOSTLT_URI="http://github.com/haubi/host-libtool/releases/download/v${HOSTLTV}/${HOSTLT}.tar.gz"
SRC_URI="mirror://gnu/${PN}/${MY_P}.tar.gz $(patches) ${HOSTLT_URI}"
HOSTLT_S=${WORKDIR}/${HOSTLT}

LICENSE="GPL-3"
SLOT="0"

# see bug 530890 before installing on OS X
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="static-libs"

RDEPEND=">=sys-libs/ncurses-5.9-r3[${MULTILIB_USEDEP}]
	abi_x86_32? (
		!app-emulation/emul-linux-x86-baselibs[-abi_x86_32(-)]
		!<=app-emulation/emul-linux-x86-baselibs-20131008-r7
	)"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${HOSTLT}.tar.gz
	S="${HOSTLT_S}" elibtoolize
	unpack ${MY_P}.tar.gz
}

src_prepare() {
	[[ ${PLEVEL} -gt 0 ]] && epatch $(patches -s)

	epatch "${FILESDIR}"/${PN}-5.0-no_rpath.patch
	epatch "${FILESDIR}"/${PN}-5.1-rlfe-extern.patch
	epatch "${FILESDIR}"/${PN}-5.2-rlfe-aix-eff_uid.patch
	epatch "${FILESDIR}"/${PN}-5.2-rlfe-hpux.patch
	epatch "${FILESDIR}"/${PN}-5.2-ia64hpux.patch
	epatch "${FILESDIR}"/${PN}-6.0-mint.patch
	epatch "${FILESDIR}"/${PN}-6.0-rlfe-solaris.patch
	epatch "${FILESDIR}"/${PN}-6.1-aix-soname.patch
	epatch "${FILESDIR}"/${PN}-6.1-aix-expfull.patch
	epatch "${FILESDIR}"/${PN}-6.2-rlfe-tgoto.patch #385091
	epatch "${FILESDIR}"/${PN}-6.3-libtool.patch
	epatch "${FILESDIR}"/${PN}-6.3-interix.patch
	epatch "${FILESDIR}"/${PN}-6.3-darwin-shlib-versioning.patch
	epatch "${FILESDIR}"/${PN}-6.3-fix-long-prompt-vi-search.patch

	# Force ncurses linking. #71420
	# Use pkg-config to get the right values. #457558
	local ncurses_libs=$($(tc-getPKG_CONFIG) ncurses --libs)
	sed -i \
		-e "/^SHLIB_LIBS=/s:=.*:='${ncurses_libs}':" \
		support/shobj-conf || die
	sed -i \
		-e "/^[[:space:]]*LIBS=.-lncurses/s:-lncurses:${ncurses_libs}:" \
		examples/rlfe/configure || die

	# fix building under Gentoo/FreeBSD; upstream FreeBSD deprecated
	# objformat for years, so we don't want to rely on that.
	sed -i -e '/objformat/s:if .*; then:if true; then:' support/shobj-conf || die

	# support more recent OS X versions
	sed -i -e 's/darwin10\*/darwin1\[01234\]\*/g' support/shobj-conf || die

	ln -s ../.. examples/rlfe/readline # for local readline headers
}

src_configure() {
	cd "${HOSTLT_S}" || die
	econf $(use_enable static-libs static)
	export PATH="${HOSTLT_S}:${PATH}"
	cd "${S}"

	# fix implicit decls with widechar funcs
	append-cppflags -D_GNU_SOURCE
	# http://lists.gnu.org/archive/html/bug-readline/2010-07/msg00013.html
	append-cppflags -Dxrealloc=_rl_realloc -Dxmalloc=_rl_malloc -Dxfree=_rl_free

	# Make sure configure picks a better ar than `ar`. #484866
	export ac_cv_prog_AR=$(tc-getAR)

	# Force the test since we used sed above to force it.
	export bash_cv_termcap_lib=ncurses

	# Control cross-compiling cases when we know the right answer.
	# In cases where the C library doesn't support wide characters, readline
	# itself won't work correctly, so forcing the answer below should be OK.
	if tc-is-cross-compiler ; then
		export bash_cv_func_sigsetjmp='present'
		export bash_cv_func_ctype_nonascii='yes'
		export bash_cv_wcwidth_broken='no' #503312
	fi

	# This is for rlfe, but we need to make sure LDFLAGS doesn't change
	# so we can re-use the config cache file between the two.
	append-ldflags -L.
	export LDFLAGS="-L${S}/shlib ${LDFLAGS}" # search local dirs first

	multilib-minimal_src_configure
}

multilib_src_configure() {
	ECONF_SOURCE=${S} \
	econf \
		--cache-file="${BUILD_DIR}"/config.cache \
		--docdir="${EPREFIX}"/usr/share/doc/${PF} \
		--with-curses \
		--disable-shared # use libtool instead

	if multilib_is_native_abi && ! tc-is-cross-compiler ; then
		# code is full of AC_TRY_RUN()
		mkdir -p examples/rlfe || die
		cd examples/rlfe || die
		ECONF_SOURCE=${S}/examples/rlfe \
		econf --cache-file="${BUILD_DIR}"/config.cache
	fi
}

multilib_src_compile() {
	emake shared || die

	if multilib_is_native_abi && ! tc-is-cross-compiler ; then
		# code is full of AC_TRY_RUN()
		cd examples/rlfe || die
		local l
		for l in readline history ; do
			ln -s ../../shlib/lib${l}$(get_libname)* lib${l}$(get_libname)
			ln -sf ../../lib${l}.a lib${l}.a
		done
		emake LTLINK='libtool --mode=link --tag=CC' || die
	fi
}

multilib_src_install() {
	export PATH="${HOSTLT_S}:${PATH}"
	emake DESTDIR="${D}" install-shared || die

	if multilib_is_native_abi ; then
		if ! tc-is-cross-compiler; then
			dobin examples/rlfe/rlfe
		fi

		# must come after installing rlfe, bug #455512
		gen_usr_ldscript -a readline history #4411
	fi
}

multilib_src_install_all() {
	einstalldocs
	dodoc USAGE
	dohtml -r doc/.
	docinto ps
	dodoc doc/*.ps
}

pkg_preinst() {
	preserve_old_lib /$(get_libdir)/lib{history,readline}$(get_libname 4) #29865
	preserve_old_lib /$(get_libdir)/lib{history,readline}$(get_libname 5) #29865
}

pkg_postinst() {
	preserve_old_lib_notify /$(get_libdir)/lib{history,readline}$(get_libname 4)
	preserve_old_lib_notify /$(get_libdir)/lib{history,readline}$(get_libname 5)
}
