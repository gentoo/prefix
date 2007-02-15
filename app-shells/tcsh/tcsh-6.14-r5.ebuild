# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/tcsh/tcsh-6.14-r5.ebuild,v 1.1 2006/12/05 14:58:35 grobian Exp $

EAPI="prefix"

inherit eutils

MY_P="${P}.00"
DESCRIPTION="Enhanced version of the Berkeley C shell (csh)"
HOMEPAGE="http://www.tcsh.org/"
SRC_URI="ftp://ftp.astron.com/pub/tcsh/${MY_P}.tar.gz
	mirror://gentoo/${P}-conffiles.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-solaris"

IUSE="perl catalogs"

DEPEND=">=sys-libs/ncurses-5.1
	perl? ( dev-lang/perl )
	!app-shells/csh" # bug #119703

S=${WORKDIR}/${MY_P}


src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}/${MY_P}"-debian-dircolors.patch # bug #120792
	epatch "${FILESDIR}/${P}"-r2.patch
	epatch "${FILESDIR}/${P}"-makefile.patch # bug #151951
	epatch "${FILESDIR}/${P}"-r4.patch

	if use catalogs ; then
		einfo "enabling NLS catalogs support..."
		sed -i -e "s/#undef NLS_CATALOGS/#define NLS_CATALOGS/" \
			${WORKDIR}/${MY_P}/config_f.h || die
		eend $?
	fi

	# the following patch makes tcsh prefix aware for it's config files
	epatch "${FILESDIR}/${P}"-prefix.patch
	sed -i -e "s:\@PREFIX\@:${EPREFIX}:g" gentoo/* \
		|| die "sed failed"
}

src_compile() {
	econf \
		$(with_bindir) \
		--libdir=${EPREFIX}/usr/$(get_libdir) \
		|| die "econf failed"
	emake || die "compile problem"
}

src_install() {
	einstall \
		bindir=${ED}/bin \
		libdir=${ED}/usr/$(get_libdir) \
		install.man \
		|| die "make install failed"

	if use perl ; then
		perl tcsh.man2html || die
		dohtml tcsh.html/*.html
	fi

	insinto /etc
	doins \
		"${WORKDIR}"/gentoo/csh.cshrc \
		"${WORKDIR}"/gentoo/csh.login

	insinto /etc/profile.d
	doins \
		"${WORKDIR}"/gentoo/tcsh-bindkey.csh \
		"${WORKDIR}"/gentoo/tcsh-settings.csh

	dodoc FAQ Fixes NewThings Ported README WishList Y2K

	docinto examples
	dodoc \
		"${WORKDIR}"/gentoo/tcsh-aliases \
		"${WORKDIR}"/gentoo/tcsh-complete \
		"${WORKDIR}"/gentoo/tcsh-gentoo_legacy \
		"${WORKDIR}"/gentoo/tcsh.config

	# bug #119703: add csh -> tcsh symlink
	dosym /bin/tcsh /bin/csh
}
