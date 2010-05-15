# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-session/gnome-session-2.26.2-r1.ebuild,v 1.6 2010/04/05 14:59:25 armin76 Exp $

EAPI="2"

inherit eutils gnome2

DESCRIPTION="Gnome session manager"
HOMEPAGE="http://www.gnome.org/"
SRC_URI="${SRC_URI}
	mirror://gentoo/${PN}-2.26.2-session-saving-button.patch.bz2
	branding? ( mirror://gentoo/gentoo-splash.png )"

LICENSE="GPL-2 LGPL-2 FDL-1.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"

IUSE="branding doc ipv6 policykit elibc_FreeBSD"

RDEPEND=">=dev-libs/glib-2.16
	>=x11-libs/gtk+-2.11.1
	>=gnome-base/libglade-2.3.6
	>=dev-libs/dbus-glib-0.76
	>=gnome-base/gconf-2
	>=x11-libs/startup-notification-0.9
	policykit? ( >=gnome-extra/policykit-gnome-0.7 )
	elibc_FreeBSD? ( dev-libs/libexecinfo )

	x11-libs/libSM
	x11-libs/libICE
	x11-libs/libX11
	x11-libs/libXtst
	x11-apps/xdpyinfo"
DEPEND="${RDEPEND}
	>=dev-lang/perl-5
	>=sys-devel/gettext-0.10.40
	>=dev-util/pkgconfig-0.17
	>=dev-util/intltool-0.40
	!<gnome-base/gdm-2.20.4
	doc? (
		app-text/xmlto
		dev-libs/libxslt )"
# gnome-base/gdm does not provide gnome.desktop anymore

DOCS="AUTHORS ChangeLog NEWS README"

pkg_setup() {
	# TODO: convert libnotify to a configure option
	G2CONF="${G2CONF}
		--docdir="${EPREFIX}"/usr/share/doc/${PF}
		$(use_enable doc docbook-docs)
		$(use_enable ipv6)
		$(use_enable policykit polkit)"
}

src_prepare() {
	gnome2_src_prepare

	# Patch for Gentoo Branding (bug #42687)
	use branding && epatch "${FILESDIR}/${PN}-2.17.90.1-gentoo-branding.patch"

	# Fix shutdown/restart capability, upstream bug #549150
	epatch "${FILESDIR}/${PN}-2.26.2-shutdown.patch"

	# Add "session saving" button back, upstream bug #575544
	epatch "${WORKDIR}/${PN}-2.26.2-session-saving-button.patch"

	# Do not crash when xsmp->priv->conn is NULL for a given GsmXsmpClient,
	# when SMS connection dies, bug #271023, import from 2.28 dev cycle.
	epatch "${FILESDIR}/${P}-xsmp-stop-throw-error.patch"
}

src_install() {
	gnome2_src_install

	dodir /etc/X11/Sessions
	exeinto /etc/X11/Sessions
	doexe "${FILESDIR}/Gnome" || die "doexe failed"

	# Our own splash for world domination
	if use branding ; then
		insinto /usr/share/pixmaps/splash/
		doins "${DISTDIR}/gentoo-splash.png" || die "doins failed"
	fi
}
