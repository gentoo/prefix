# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/dialog/dialog-1.1.20120215.ebuild,v 1.9 2012/06/07 21:27:50 ranger Exp $

EAPI="4"

inherit multilib

MY_PV="${PV/1.1./1.1-}"
S=${WORKDIR}/${PN}-${MY_PV}
DESCRIPTION="tool to display dialog boxes from a shell"
HOMEPAGE="http://invisible-island.net/dialog/dialog.html"
SRC_URI="ftp://invisible-island.net/${PN}/${PN}-${MY_PV}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="examples minimal nls static-libs unicode"

RDEPEND="
	>=app-shells/bash-2.04-r3
	!unicode? ( >=sys-libs/ncurses-5.2-r5 )
	unicode? ( >=sys-libs/ncurses-5.2-r5[unicode] )
"
DEPEND="
	${RDEPEND}
	nls? ( sys-devel/gettext )
	!minimal? ( sys-devel/libtool )
	!<=sys-freebsd/freebsd-contrib-8.9999
"

src_prepare() {
	sed -i configure -e '/LIB_CREATE=/s:${CC}:& ${LDFLAGS}:g' || die
	# configure searches all over the world for some things...
	sed -i configure \
		-e 's:^test -d "\(/usr\|$prefix\|/usr/local\|/opt\|$HOME\):test -d "XnoX:' || die
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
		--disable-rpath-hack \
		$(use_enable nls) \
		$(use_with !minimal libtool) \
		--with-ncurses${ncursesw}
}

src_install() {
	if use minimal; then
		emake DESTDIR="${D}" install
	else
		emake DESTDIR="${D}" install-full
	fi

	dodoc CHANGES README VERSION

	if use examples; then
		docinto samples
		dodoc $( find samples -maxdepth 1 -type f )
		docinto samples/copifuncs
		dodoc $( find samples/copifuncs -maxdepth 1 -type f )
		docinto samples/install
		dodoc $( find samples/install -type f )
	fi

	if ! use static-libs; then
		rm -f \
			"${ED}"usr/$(get_libdir)/libdialog.a \
			"${ED}"usr/$(get_libdir)/libdialog.la
	fi
}
