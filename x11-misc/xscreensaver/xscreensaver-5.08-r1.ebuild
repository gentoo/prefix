# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xscreensaver/xscreensaver-5.08-r1.ebuild,v 1.3 2009/04/30 20:16:53 ssuominen Exp $

EAPI=2
inherit autotools eutils flag-o-matic multilib pam

DESCRIPTION="A modular screen saver and locker for the X Window System"
SRC_URI="http://www.jwz.org/xscreensaver/${P}.tar.gz"
HOMEPAGE="http://www.jwz.org/xscreensaver"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x64-solaris ~x86-solaris"
IUSE="jpeg new-login opengl pam suid xinerama"

RDEPEND="x11-libs/libXmu
	x11-libs/libXxf86vm
	x11-libs/libXrandr
	x11-libs/libXxf86misc
	x11-libs/libXt
	x11-libs/libX11
	x11-libs/libXext
	x11-apps/xwininfo
	x11-apps/appres
	media-libs/netpbm
	>=dev-libs/libxml2-2.5
	>=x11-libs/gtk+-2:2
	>=gnome-base/libglade-1.99
	pam? ( virtual/pam )
	jpeg? ( media-libs/jpeg )
	opengl? ( virtual/opengl )
	xinerama? ( x11-libs/libXinerama )
	new-login? ( gnome-base/gdm )"
DEPEND="${RDEPEND}
	x11-proto/xf86vidmodeproto
	x11-proto/xextproto
	x11-proto/scrnsaverproto
	x11-proto/recordproto
	x11-proto/xf86miscproto
	sys-devel/bc
	dev-util/pkgconfig
	sys-devel/gettext
	dev-util/intltool
	xinerama? ( x11-proto/xineramaproto )"

src_prepare() {
	epatch "${FILESDIR}"/${PV}/01_all_default_settings.patch \
		"${FILESDIR}"/${PV}/03_all_glforrestfire.patch \
		"${FILESDIR}"/${P}-phosphor-segv.patch \
		"${FILESDIR}"/${P}-po-recreate.patch
	epatch "${FILESDIR}"/${PN}-5.05-interix.patch
	eautoconf
}

src_configure() {
	if use ppc || use ppc64; then
		filter-flags -mabi=altivec
		filter-flags -maltivec
		append-flags -U__VEC__
	fi

	unset LINGUAS #113681
	unset BC_ENV_ARGS #24568

	econf \
		--with-x-app-defaults="${EPREFIX}"/usr/share/X11/app-defaults \
		--with-hackdir="${EPREFIX}"/usr/$(get_libdir)/misc/xscreensaver \
		--with-configdir="${EPREFIX}"/usr/share/${PN}/config \
		--x-libraries="${EPREFIX}"/usr/$(get_libdir) \
		--x-includes="${EPREFIX}"/usr/include \
		--with-dpms-ext \
		--with-xf86vmode-ext \
		--with-xf86gamma-ext \
		--with-randr-ext \
		--with-proc-interrupts \
		--with-xshm-ext \
		--with-xdbe-ext \
		--enable-locking \
		--without-kerberos \
		--without-gle \
		--with-gtk \
		--with-pixbuf \
		--with-text-file="${EPREFIX}"/etc/gentoo-release \
		$(use_with suid setuid-hacks) \
		$(use_with new-login login-manager) \
		$(use_with xinerama xinerama-ext) \
		$(use_with pam) \
		$(use_with opengl gl) \
		$(use_with jpeg)
}

src_compile() {
	emake -j1 || die "emake failed." #155049
}

src_install() {
	emake install_prefix="${D}" install || die "emake install failed."
	dodoc README{,.hacking}

	use pam && fperms 755 /usr/bin/${PN}
	pamd_mimic_system ${PN} auth

	# Collision with electricsheep, bug 135549
	rm -f "${ED}"/usr/share/${PN}/config/{electricsheep,fireflies}.xml
}
