# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xscreensaver/xscreensaver-5.05.ebuild,v 1.11 2008/05/07 19:03:33 drac Exp $

EAPI="prefix"

inherit autotools eutils flag-o-matic multilib pam

DESCRIPTION="A modular screen saver and locker for the X Window System"
SRC_URI="http://www.jwz.org/xscreensaver/${P}.tar.gz"
HOMEPAGE="http://www.jwz.org/xscreensaver"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="jpeg new-login opengl pam suid xinerama"

RDEPEND="x11-libs/libXxf86misc
	x11-apps/xwininfo
	x11-apps/appres
	media-libs/netpbm
	>=dev-libs/libxml2-2.5
	>=x11-libs/gtk+-2
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

src_unpack() {
	unpack ${A}
	cd "${S}"
	EPATCH_SUFFIX="patch" EPATCH_EXCLUDE="07_all_xinerama.patch" epatch	"${FILESDIR}"/${PV}
	epatch "${FILESDIR}"/${P}-interix.patch
	eautoreconf # bug 113681
}

src_compile() {
	if use ppc || use ppc64; then
		# Simple workaround for the ppc* arches flurry screensaver, needed for <=5.04
		filter-flags -mabi=altivec
		filter-flags -maltivec
		append-flags -U__VEC__
	fi

	unset BC_ENV_ARGS

	[[ ${CHOST} == *-interix* ]] && append-flags -D_ALL_SOURCE

	econf \
		--with-x-app-defaults="${EPREFIX}"/usr/share/X11/app-defaults \
		--with-hackdir="${EPREFIX}"/usr/$(get_libdir)/misc/xscreensaver \
		--with-configdir="${EPREFIX}"/usr/share/${PN}/config \
		--x-libraries="${EPREFIX}"/usr/$(get_libdir) \
		--x-includes="${EPREFIX}"/usr/include \
		--with-dpms-ext \
		--with-xf86vmode-ext \
		--with-xf86gamma-ext \
		--with-proc-interrupts \
		--with-xpm \
		--with-xshm-ext \
		--with-xdbe-ext \
		--enable-locking \
		--without-kerberos \
		--without-gle \
		--with-gtk \
		$(use_with suid setuid-hacks) \
		$(use_with new-login login-manager) \
		$(use_with xinerama xinerama-ext) \
		$(use_with pam) \
		$(use_with opengl gl) \
		$(use_with jpeg)

	# Bug 155049.
	emake -j1 || die "emake failed."
}

src_install() {
	emake install_prefix="${D}" install || die "emake install failed."

	dodoc README*

	use pam && fperms 755 /usr/bin/${PN}
	pamd_mimic_system ${PN} auth

	# Bug 135549.
	rm -f "${ED}"/usr/share/${PN}/config/{electricsheep,fireflies}.xml
	dodir /usr/share/man/man6x
	mv "${ED}"/usr/share/man/man6/worm.6 \
		"${ED}"/usr/share/man/man6x/worm.6x
}
