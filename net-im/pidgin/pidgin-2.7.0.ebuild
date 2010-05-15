# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-im/pidgin/pidgin-2.7.0.ebuild,v 1.1 2010/05/13 16:03:48 tester Exp $

EAPI=2

GENTOO_DEPEND_ON_PERL=no
inherit flag-o-matic eutils toolchain-funcs multilib perl-app gnome2 autotools

DESCRIPTION="GTK Instant Messenger client"
HOMEPAGE="http://pidgin.im/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE="dbus debug doc eds gadu gnutls idn meanwhile networkmanager"
IUSE+=" nls perl silc tcl tk spell qq gadu +gtk sasl +startup-notification"
IUSE+=" ncurses groupwise prediction +xscreensaver zephyr zeroconf" # mono"

IUSE+="aqua"

RDEPEND="
	>=dev-libs/glib-2.12
	>=dev-libs/libxml2-2.6.18
	ncurses? ( sys-libs/ncurses[unicode] )
	gtk? (
		>=x11-libs/gtk+-2.10:2[aqua=]
		x11-libs/libSM
		xscreensaver? ( x11-libs/libXScrnSaver )
		startup-notification? ( >=x11-libs/startup-notification-0.5 )
		spell? ( >=app-text/gtkspell-2.0.2 )
		eds? ( <gnome-extra/evolution-data-server-2.30 )
		prediction? ( >=dev-db/sqlite-3.3:3 ) )
	=media-libs/gstreamer-0.10*
	=media-libs/gst-plugins-good-0.10*
	>=net-libs/farsight2-0.0.14
	media-plugins/gst-plugins-meta
	media-plugins/gst-plugins-gconf
	zeroconf? ( net-dns/avahi )
	dbus? ( >=dev-libs/dbus-glib-0.71
		>=dev-python/dbus-python-0.71
		>=sys-apps/dbus-0.90
		>=dev-lang/python-2.4 )
	perl? ( >=dev-lang/perl-5.8.2-r1[-build] )
	gadu?  ( net-libs/libgadu[-ssl] )
	gnutls? ( net-libs/gnutls )
	!gnutls? ( >=dev-libs/nss-3.11 )
	meanwhile? ( net-libs/meanwhile )
	silc? ( >=net-im/silc-toolkit-1.0.1 )
	zephyr? ( >=app-crypt/mit-krb5-1.3.6-r1[krb4] )
	tcl? ( dev-lang/tcl )
	tk? ( dev-lang/tk )
	sasl? ( dev-libs/cyrus-sasl:2 )
	>=dev-libs/libxml2-2.6.18
	networkmanager? ( net-misc/networkmanager )
	prediction? ( =dev-db/sqlite-3* )
	ncurses? ( sys-libs/ncurses[unicode] )
	idn? ( net-dns/libidn )"
	# Mono support crashes pidgin
	#mono? ( dev-lang/mono )"

DEPEND="$RDEPEND
	dev-lang/perl
	dev-perl/XML-Parser
	dev-util/pkgconfig
	dev-util/intltool
	gtk? ( x11-proto/scrnsaverproto )
	doc? ( app-doc/doxygen )
	nls? ( sys-devel/gettext )"

# Enable Default protocols
DYNAMIC_PRPLS="irc,jabber,oscar,yahoo,simple,msn,myspace"

# List of plugins
#   app-accessibility/pidgin-festival
#   net-im/librvp
#   x11-plugins/guifications
#	x11-plugins/msn-pecan
#   x11-plugins/pidgin-encryption
#   x11-plugins/pidgin-extprefs
#   x11-plugins/pidgin-hotkeys
#   x11-plugins/pidgin-latex
#   x11-plugins/pidgintex
#   x11-plugins/pidgin-libnotify
#   x11-plugins/pidgin-otr
#   x11-plugins/pidgin-rhythmbox
#   x11-plugins/purple-plugin_pack
#   x11-themes/pidgin-smileys
#	x11-plugins/pidgin-knotify
# Plugins in Sunrise:
#	x11-plugins/pidgimpd
#	x11-plugins/pidgin-birthday
#	x11-plugins/pidgin-botsentry
#	x11-plugins/pidgin-convreverse
#	x11-plugins/pidgin-extended-blist-sort
#	x11-plugins/pidgin-lastfm
#	x11-plugins/pidgin-mbpurple

pkg_setup() {
	if ! use gtk && ! use ncurses ; then
		einfo
		elog "You did not pick the ncurses or gtk use flags, only libpurple"
		elog "will be built."
		einfo
	fi
	if ! use xscreensaver; then
		elog "Note: xscreensaver USE flag is disabled. Thus pidgin will be unable"
		elog "to monitor idle/active status based on mouse/keyboard events"
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.5.8-gtkdocklet-quartz.patch

	intltoolize --automake --copy --force || die
	eautoreconf
}

src_configure() {
	# Stabilize things, for your own good
	strip-flags
	replace-flags -O? -O2

	local myconf

	if use gadu; then
		DYNAMIC_PRPLS="${DYNAMIC_PRPLS},gg"
			myconf="${myconf} --with-gadu-includes=."
			myconf="${myconf} --with-gadu-libs=."
	fi

	use silc && DYNAMIC_PRPLS+=",silc"
	use qq && DYNAMIC_PRPLS+=",qq"
	use meanwhile && DYNAMIC_PRPLS+=",sametime"
	use zeroconf && DYNAMIC_PRPLS+=",bonjour"
	use groupwise && DYNAMIC_PRPLS+=",novell"
	use zephyr && DYNAMIC_PRPLS+=",zephyr"

	if use gnutls ; then
		einfo "Disabling NSS, using GnuTLS"
		myconf="${myconf} --enable-nss=no --enable-gnutls=yes"
		myconf="${myconf} --with-gnutls-includes=${EPREFIX}/usr/include/gnutls"
		myconf="${myconf} --with-gnutls-libs=${EPREFIX}/usr/$(get_libdir)"
	else
		einfo "Disabling GnuTLS, using NSS"
		myconf="${myconf} --enable-gnutls=no --enable-nss=yes"
	fi

	econf \
		$(use_enable ncurses consoleui) \
		$(use_enable nls) \
		$(use_enable gtk gtkui) \
		$(use_enable gtk sm) \
		$(use gtk && use_enable startup-notification) \
		$(use gtk && use_enable xscreensaver screensaver) \
		$(use gtk && use_enable prediction cap) \
		$(use gtk && use_enable eds gevolution) \
		$(use gtk && use_enable spell gtkspell) \
		$(use_enable perl) \
		$(use_enable tk) \
		$(use_enable tcl) \
		$(use_enable debug) \
		$(use_enable dbus) \
		$(use_enable meanwhile) \
		$(use_enable sasl cyrus-sasl ) \
		$(use_enable doc doxygen) \
		$(use_enable networkmanager nm) \
		$(use_with zephyr krb4) \
		$(use_enable zeroconf avahi) \
		$(use_enable idn) \
		$(use_enable aqua gtkstatusicon) \
		$(use_enable !aqua gestures) \
		$(use_enable !aqua startup-notification) \
		$(use_with !aqua x) \
		"--with-dynamic-prpls=${DYNAMIC_PRPLS}" \
		--disable-mono \
		--enable-gstreamer \
		--enable-farsight \
		--enable-vv \
		--x-includes="${EPREFIX}/usr/include/X11" \
		${myconf}
		#$(use_enable mono) \
}

src_install() {
	gnome2_src_install
	use perl && fixlocalpod
	dodoc AUTHORS HACKING INSTALL NEWS README ChangeLog
}
