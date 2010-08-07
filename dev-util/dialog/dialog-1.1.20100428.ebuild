# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/dialog/dialog-1.1.20100428.ebuild,v 1.1 2010/07/07 22:22:36 truedfx Exp $

# porting note:
# manpages were installed in the wrong location (double prefix)
# solution: replaced make install with einstall

EAPI=2

inherit eutils

MY_PV="${PV/1.1./1.1-}"
S=${WORKDIR}/${PN}-${MY_PV}
DESCRIPTION="tool to display dialog boxes from a shell"
HOMEPAGE="http://invisible-island.net/dialog/dialog.html"
SRC_URI="ftp://invisible-island.net/${PN}/${PN}-${MY_PV}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="examples minimal nls unicode"

RDEPEND=">=app-shells/bash-2.04-r3
	!unicode? ( >=sys-libs/ncurses-5.2-r5 )
	unicode? ( >=sys-libs/ncurses-5.2-r5[unicode] )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"


src_prepare() {
	epatch "${FILESDIR}"/${P}-shared.patch
	# configure searches all over the world for some things...
	epatch "${FILESDIR}"/${PN}-1.1-no-usr-local.patch
}

src_configure() {
	local ncursesw
	use unicode && ncursesw="w"
	# doing this libtool stuff through configure
	# (--with-libtool=/path/to/libtool) strangely breaks the build
	local glibtool="libtool"
	[[ ${CHOST} == *-darwin* ]] && glibtool="glibtool"
	export ac_cv_path_LIBTOOL="$(type -P ${glibtool})"
	econf \
		$(use_enable nls) \
		$(use_with !minimal libtool) \
		--with-ncurses${ncursesw}
}

src_install() {
	if use minimal; then
		emake DESTDIR="${D}" install || die "install failed"
	else
		emake DESTDIR="${D}" install-full || die "install failed"
	fi

	dodoc CHANGES README VERSION

	if use examples; then
		docinto samples
		dodoc samples/*
	fi
}
