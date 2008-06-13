# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/readline/readline-5.2_p12-r1.ebuild,v 1.8 2008/04/08 21:43:06 vapier Exp $

EAPI="prefix"

inherit eutils multilib toolchain-funcs flag-o-matic

# Official patches
# See ftp://ftp.cwru.edu/pub/bash/readline-5.1-patches/
PLEVEL=${PV##*_p}
MY_PV=${PV/_p*}
MY_P=${PN}-${MY_PV}

DESCRIPTION="Another cute console display library"
HOMEPAGE="http://cnswww.cns.cwru.edu/php/chet/readline/rltop.html"
SRC_URI="mirror://gnu/readline/${MY_P}.tar.gz
	$(for ((i=1; i<=PLEVEL; i++)); do
		printf 'ftp://ftp.cwru.edu/pub/bash/readline-%s-patches/readline%s-%03d\n' \
			${MY_PV} ${MY_PV/\.} ${i}
		printf 'mirror://gnu/bash/readline-%s-patches/readline%s-%03d\n' \
			${MY_PV} ${MY_PV/\.} ${i}
	done)"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
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
	# Official patches
	local i
	for ((i=1; i<=PLEVEL; i++)); do
		epatch "${DISTDIR}"/${PN}${MY_PV/\.}-$(printf '%03d' ${i})
	done
	# missing patch for 'support/shlib-install' in p12 (netbsd, aix5, interix).
	epatch "${FILESDIR}"/${P}-shlib-install.patch

	epatch "${FILESDIR}"/${PN}-5.0-no_rpath.patch
	epatch "${FILESDIR}"/${PN}-5.2-rlfe-build.patch #151174
	epatch "${FILESDIR}"/${PN}-5.1-rlfe-uclibc.patch
	epatch "${FILESDIR}"/${PN}-5.2-no-ignore-shlib-errors.patch #216952

	epatch "${FILESDIR}"/${PN}-5.1-rlfe-extern.patch
	epatch "${FILESDIR}"/${PN}-5.2-rlfe-aix-eff_uid.patch
	epatch "${FILESDIR}"/${PN}-5.2-rlfe-hpux.patch
	epatch "${FILESDIR}"/${PN}-5.2-rlfe-irix.patch #209595
	epatch "${FILESDIR}"/${PN}-5.2-interix.patch
	epatch "${FILESDIR}"/${PN}-5.2-ia64hpux.patch
	epatch "${FILESDIR}"/${PN}-5.2-aixdll.patch
	epatch "${FILESDIR}"/${PN}-5.2-solaris-fPIC.patch
	[[ ${CHOST} == *-darwin9 ]] && epatch "${FILESDIR}"/${PN}-5.2-darwin9-rlfe.patch

	ln -s ../.. examples/rlfe/readline

	# force ncurses linking #71420
	sed -i -e 's:^SHLIB_LIBS=:SHLIB_LIBS=-lncurses:' support/shobj-conf || die "sed"
}

src_compile() {
	append-flags -D_GNU_SOURCE

	# the --libdir= is needed because if lib64 is a directory, it will default
	# to using that... even if CONF_LIBDIR isnt set or we're using a version
	# of portage without CONF_LIBDIR support.
	econf --with-curses --libdir="${EPREFIX}"/$(get_libdir) || die
	emake || die

	if ! tc-is-cross-compiler ; then
		cd examples/rlfe
		econf || die
		emake || die "make rlfe failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die

	# Move static and extraneous ncurses libraries out of /lib
	dodir /usr/$(get_libdir)
	[[ $(get_libname) != .a ]] &&
	mv "${ED}"/$(get_libdir)/lib{readline,history}.a "${ED}"/usr/$(get_libdir)/
	chmod u+w "${ED}"/$(get_libdir)/*$(get_libname)*
	# Bug #4411
	gen_usr_ldscript lib{readline,history}$(get_libname)
	chmod a+rx "${ED}"/$(get_libdir)/*$(get_libname)*

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
}

pkg_postinst() {
	preserve_old_lib_notify /$(get_libdir)/lib{history,readline}$(get_libname 4)
}
