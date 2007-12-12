# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/tcsh/tcsh-6.15-r2.ebuild,v 1.11 2007/12/11 09:25:29 vapier Exp $

EAPI="prefix"

inherit eutils flag-o-matic autotools

CONFVER="1.8"

MY_P="${P}.00"
DESCRIPTION="Enhanced version of the Berkeley C shell (csh)"
HOMEPAGE="http://www.tcsh.org/"
SRC_URI="ftp://ftp.astron.com/pub/tcsh/${MY_P}.tar.gz
	mirror://gentoo/tcsh-config-prefix-${CONFVER}.tar.bz2
	http://www.gentoo.org/~grobian/distfiles/tcsh-config-prefix-${CONFVER}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"

IUSE="perl catalogs"
RESTRICT="test"

# we need gettext because we run autoconf
DEPEND=">=sys-libs/ncurses-5.1
	sys-devel/gettext
	perl? ( dev-lang/perl )
	!app-shells/csh" # bug #119703

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${MY_P/15/14}"-debian-dircolors.patch # bug #120792
	epatch "${FILESDIR}"/${PN}-6.14-makefile.patch # bug #151951
	epatch "${FILESDIR}"/${MY_P}-normalize-command-fix.patch # bug #183754
	epatch "${FILESDIR}"/${PN}-6.14-use-ncurses.patch
	eautoreconf

	if use catalogs ; then
		einfo "enabling NLS catalogs support..."
		sed -i -e "s/#undef NLS_CATALOGS/#define NLS_CATALOGS/" \
			config_f.h || die
		eend $?
	fi

	eprefixify "${WORKDIR}"/tcsh-config/*
}

src_compile() {
	# make tcsh look and live along the lines of the prefix
	append-flags -D_PATH_DOTCSHRC="'"'"${EPREFIX}/etc/csh.cshrc"'"'"
	append-flags -D_PATH_DOTLOGIN="'"'"${EPREFIX}/etc/csh.login"'"'"
	append-flags -D_PATH_DOTLOGOUT="'"'"${EPREFIX}/etc/csh.logout"'"'"
	append-flags -D_PATH_USRBIN="'"'"${EPREFIX}/usr/bin"'"'"
	append-flags -D_PATH_BIN="'"'"${EPREFIX}/bin"'"'"

	econf --prefix="${EPREFIX}" || die "econf failed"
	emake || die "compile problem"
}

src_install() {
	emake DESTDIR="${D}" install install.man || die

	if use perl ; then
		perl tcsh.man2html tcsh.man || die
		dohtml tcsh.html/*.html
	fi

	insinto /etc
	doins \
		"${WORKDIR}"/tcsh-config/csh.cshrc \
		"${WORKDIR}"/tcsh-config/csh.login

	dodoc FAQ Fixes NewThings Ported README WishList Y2K

	# bug #119703: add csh -> tcsh symlink
	dosym /bin/tcsh /bin/csh
}

pkg_postinst() {
	elog "This revision of tcsh does use a completely revamped configuration"
	elog "files system, which is based on the bash equivalents.  It should"
	elog "fix issues for KDE users, and miscelaneous issues of environment"
	elog "variables not set that should have, like EDITOR.  If you rely"
	elog "on the /etc/csh.* files heavily, you may find your setup will be"
	elog "broken now."
}
