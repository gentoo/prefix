# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-irc/xchat/xchat-2.8.6-r3.ebuild,v 1.2 2010/04/25 17:46:16 armin76 Exp $

EAPI=2

inherit eutils versionator gnome2 autotools

DESCRIPTION="Graphical IRC client"
SRC_URI="http://www.xchat.org/files/source/$(get_version_component_range 1-2)/${P}.tar.bz2
	mirror://sourceforge/${PN}/${P}.tar.bz2
	xchatdccserver? ( mirror://gentoo/${PN}-dccserver-0.6.patch.bz2 )"
HOMEPAGE="http://www.xchat.org/"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="dbus ipv6 libnotify mmx nls ntlm perl python spell ssl tcl xchatnogtk xchatdccserver xft"

RDEPEND=">=dev-libs/glib-2.6.0
	!xchatnogtk? ( >=x11-libs/gtk+-2.10.0 )
	ssl? ( >=dev-libs/openssl-0.9.6d )
	perl? ( >=dev-lang/perl-5.6.1 )
	python? ( >=dev-lang/python-2.2 )
	tcl? ( dev-lang/tcl )
	dbus? ( >=dev-libs/dbus-glib-0.71 )
	spell? ( app-text/gtkspell )
	libnotify? ( x11-libs/libnotify )
	ntlm? ( net-libs/libntlm )
	!<net-irc/xchat-gnome-0.9"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.7
	nls? ( sys-devel/gettext )"

src_prepare() {
	use xchatdccserver && epatch "${DISTDIR}"/xchat-dccserver-0.6.patch.bz2

	# use libdir/xchat/plugins as the plugin directory
	if [ $(get_libdir) != "lib" ] ; then
		sed -i -e 's:${prefix}/lib/xchat:${libdir}/xchat:' \
			"${S}"/configure{,.in} || die
	fi

	epatch "${FILESDIR}"/xc286-smallfixes.diff
	epatch "${FILESDIR}"/${P}-shm-pixmaps.patch
	# bug #286146
	epatch "${FILESDIR}"/${P}-fix-button-underlines.patch
	# bug #294636
	epatch "${FILESDIR}"/${P}-automagic-ntlm-configure-fix.patch

	epatch "${FILESDIR}"/${PN}-2.8.4-interix.patch

	# don't disable deprecated gtk+ symbols, it's not forwards compatible, bug 234458
	sed -i -e '/define GTK_DISABLE_DEPRECATED/d' src/fe-gtk/*.c

	eautoreconf # need new libtool for interix
}

src_configure() {
	# xchat's configure script uses sys.path to find library path
	# instead of python-config (#25943)
	unset PYTHONPATH

	[[ ${CHOST} == *-interix* ]] && {
		# this -Wl,-E option for the interix ld makes some checks
		# false positives, so set those here.
		export ac_cv_func_strtoull=no
		export ac_cv_func_memrchr=no
	}

	econf \
		--enable-shm \
		$(use_enable dbus) \
		$(use_enable ipv6) \
		$(use_enable mmx) \
		$(use_enable nls) \
		$(use_enable ntlm) \
		$(use_enable perl) \
		$(use_enable python) \
		$(use_enable spell spell gtkspell) \
		$(use_enable ssl openssl) \
		$(use_enable tcl) \
		$(use_enable !xchatnogtk gtkfe) \
		$(use_enable xft)
}

src_install() {
	USE_DESTDIR=1 gnome2_src_install || die "make install failed"

	# install plugin development header
	insinto /usr/include/xchat
	doins src/common/xchat-plugin.h || die "doins failed"

	dodoc ChangeLog README* || die "dodoc failed"
}

pkg_postinst() {
	elog
	elog "XChat binary has been renamed from xchat-2 to xchat."
	elog

	if has_version net-irc/xchat-systray
	then
		elog "XChat now includes it's own systray icon, you may want to remove net-irc/xchat-systray."
		elog
	fi
}
