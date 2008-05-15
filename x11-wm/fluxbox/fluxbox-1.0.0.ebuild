# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/fluxbox/fluxbox-1.0.0.ebuild,v 1.8 2007/11/16 16:43:50 nixnut Exp $

EAPI="prefix"

inherit eutils

IUSE="nls xinerama truetype kde gnome imlib disableslit disabletoolbar"

DESCRIPTION="Fluxbox is an X11 window manager featuring tabs and an iconbar"

SRC_URI="mirror://sourceforge/fluxbox/${P}.tar.bz2"
HOMEPAGE="http://www.fluxbox.org"

# Please note that USE="kde gnome" simply adds support for the respective
# protocols, and does not depend on external libraries. They do, however,
# make the binary a fair bit bigger, so we don't want to turn them on unless
# the user actually wants them.

RDEPEND="x11-libs/libXpm
	x11-libs/libXrandr
	xinerama? ( x11-libs/libXinerama )
	x11-apps/xmessage
	virtual/xft
	truetype? ( media-libs/freetype )
	imlib? ( >=media-libs/imlib2-1.2.0 )
	!<x11-themes/fluxbox-styles-fluxmod-20040809-r1
	!<=x11-misc/fluxconf-0.9.9
	!<=x11-misc/fbdesk-1.2.1"
DEPEND="nls? ( sys-devel/gettext )
	x11-proto/xextproto
	xinerama? ( x11-proto/xineramaproto )
	${RDEPEND}"
PROVIDE="virtual/blackbox"

SLOT="0"
LICENSE="MIT"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux"

pkg_setup() {
	if use imlib && ! built_with_use media-libs/imlib2 X ; then
			eerror "To build fluxbox with imlib in USE, you need an X enabled"
			eerror "media-libs/imlib2 . Either recompile imlib2 with the X"
			eerror "USE flag turned on or disable the imlib USE flag for fluxbox."
			die "USE=imlib requires imlib2 with USE=X"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# We need to be able to include directories rather than just plain
	# files in menu [include] items. This patch will allow us to do clever
	# things with style ebuilds.
	epatch "${FILESDIR}/${PV}/gentoo_style_location.patch"

	# Add in the Gentoo -r number to fluxbox -version output.
	if [[ "${PR}" == "r0" ]] ; then
		suffix="gentoo"
	else
		suffix="gentoo-${PR}"
	fi
	sed -i \
		-e "s~\(__fluxbox_version .@VERSION@\)~\1-${suffix}~" \
		version.h.in || die "version sed failed"
}

src_compile() {
	econf \
		$(use_enable nls) \
		$(use_enable xinerama) \
		$(use_enable truetype xft) \
		$(use_enable kde) \
		$(use_enable gnome) \
		$(use_enable imlib imlib2) \
		$(use_enable !disableslit slit ) \
		$(use_enable !disabletoolbar toolbar ) \
		--sysconfdir=/etc/X11/${PN} \
		--with-style=/usr/share/fluxbox/styles/Emerge \
		${myconf} || die "configure failed"

	emake || die "make failed"

	ebegin "Creating a menu file (may take a while)"
	mkdir -p "${T}/home/.fluxbox" || die "mkdir home failed"
	MENUFILENAME="${S}/data/menu" MENUTITLE="Fluxbox ${PV}" \
		CHECKINIT="no. go away." HOME="${T}/home" \
		"${S}/util/fluxbox-generate_menu" -is -ds \
		|| die "menu generation failed"
	eend $?
}

src_install() {
	dodir /usr/share/fluxbox
	emake DESTDIR="${D}" install || die "install failed"
	dodoc README* AUTHORS TODO* ChangeLog NEWS

	dodir /usr/share/xsessions
	insinto /usr/share/xsessions
	doins "${FILESDIR}/${PN}.desktop"

	dodir /etc/X11/Sessions
	echo "/usr/bin/startfluxbox" > "${ED}/etc/X11/Sessions/fluxbox"
	fperms a+x /etc/X11/Sessions/fluxbox

	dodir /usr/share/fluxbox/menu.d

	# Styles menu framework
	dodir /usr/share/fluxbox/menu.d/styles
	insinto /usr/share/fluxbox/menu.d/styles
	doins "${FILESDIR}/styles-menu-fluxbox" || die
	doins "${FILESDIR}/styles-menu-commonbox" || die
	doins "${FILESDIR}/styles-menu-user" || die
}
