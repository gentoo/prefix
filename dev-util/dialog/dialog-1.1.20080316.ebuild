# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/dialog/dialog-1.1.20080316.ebuild,v 1.3 2008/05/12 14:36:36 corsair Exp $

EAPI="prefix"

# porting note:
# manpages were installed in the wrong location (double prefix)
# solution: replaced make install with einstall

inherit eutils

MY_PV="${PV/1.1./1.1-}"
S=${WORKDIR}/${PN}-${MY_PV}
DESCRIPTION="tool to display dialog boxes from a shell"
HOMEPAGE="http://invisible-island.net/dialog/dialog.html"
SRC_URI="ftp://invisible-island.net/${PN}/${PN}-${MY_PV}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="examples nls unicode"

RDEPEND=">=app-shells/bash-2.04-r3
	>=sys-libs/ncurses-5.2-r5"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

pkg_setup() {
	if use unicode && ! built_with_use sys-libs/ncurses unicode; then
		eerror "Installing dialog with the unicode flag requires ncurses be"
		eerror "built with it as well. Please make sure your /etc/make.conf"
		eerror "or /etc/portage/package.use enables it, and re-install"
		eerror "ncurses with \`emerge --oneshot sys-libs/ncurses\`."
		die "Re-emerge ncurses with the unicode flag"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# configure searches all over the world for some things...
	epatch "${FILESDIR}"/${PN}-1.1-no-usr-local.patch
}

src_compile() {
	use unicode && ncursesw="w"
	econf $(use_enable nls) \
		"--with-ncurses${ncursesw}" || die "configure failed"
	emake || die "build failed"
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc CHANGES README VERSION

	if use examples; then
		docinto samples
		dodoc samples/*
	fi
}
