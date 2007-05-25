# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/fluxbox/fluxbox-1.0_rc3-r2.ebuild,v 1.1 2007/05/14 21:23:18 lack Exp $

EAPI="prefix"

inherit eutils

IUSE="nls xinerama truetype kde gnome imlib disableslit disabletoolbar"

DESCRIPTION="Fluxbox is an X11 window manager featuring tabs and an iconbar"
MY_P="fluxbox-1.0rc3"

S="${WORKDIR}/${MY_P}"
SRC_URI="mirror://sourceforge/fluxbox/${MY_P}.tar.bz2"
HOMEPAGE="http://www.fluxbox.org"

# Please note that USE="kde gnome" simply adds support for the respective
# protocols, and does not depend on external libraries. They do, however,
# make the binary a fair bit bigger, so we don't want to turn them on unless
# the user actually wants them.

RDEPEND="|| ( ( x11-libs/libXpm
			x11-libs/libXrandr
			xinerama? ( x11-libs/libXinerama )
			x11-apps/xmessage
		)
		virtual/x11
	)
	virtual/xft
	truetype? ( media-libs/freetype )
	imlib? ( >=media-libs/imlib2-1.2.0 )
	!<x11-themes/fluxbox-styles-fluxmod-20040809-r1"
DEPEND=">=sys-devel/autoconf-2.52
		nls? ( sys-devel/gettext )
		|| ( ( x11-proto/xextproto
				xinerama? ( x11-proto/xineramaproto )
			)
			virtual/x11
		)
		${RDEPEND}"
PROVIDE="virtual/blackbox"

SLOT="0"
LICENSE="MIT"
KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~x86 ~x86-solaris"

pkg_setup() {
	if use imlib ; then
		if ! built_with_use media-libs/imlib2 X ; then
			eerror "To build fluxbox with imlib in USE, you need an X enabled"
			eerror "media-libs/imlib2 . Either recompile imlib2 with the X"
			eerror "USE flag turned on or disable the imlib USE flag for fluxbox."
			die "USE=imlib requires imlib2 with USE=X"
		fi
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# We need to be able to include directories rather than just plain
	# files in menu [include] items. This patch will allow us to do clever
	# things with style ebuilds.
	epatch "${FILESDIR}/1.0_rc3/${PN}-1.0_rc3-our-styles-go-over-here.patch" ||	die "Patch failed"

	# Bug 177114 - Segfault for certain locales
	epatch "${FILESDIR}/1.0_rc3/${PN}-1.0_rc3-textproperties_segfault.patch" ||	die "Patch failed"

	# Some "bottom" windows, notably ROX Filer's panel, cause a flicker sometimes
	epatch "${FILESDIR}/1.0_rc3/${PN}-1.0_rc3-flicker.patch" ||	die "Patch failed"

	# Bug 176476 - Missing icons from fluxbox-generate_menu
	epatch "${FILESDIR}/1.0_rc3/fluxbox-1.0_rc3-generate_menu_icon_fix.patch" ||	die "Patch failed"

	# Add in the Gentoo -r number to fluxbox -version output.
	if [[ "${PR}" == "r0" ]] ; then
		suffix="gentoo"
	else
		suffix="gentoo-${PR}"
	fi
	sed -i \
		-e "s~\(__fluxbox_version .@VERSION@\)~\1-${suffix}~" \
		version.h.in || die "version sed failed"

	# Turn on aa by default if possible. Fluxbox fonts are really frickin'
	# broken, we'll do what we can to make it less painful by default.
	use truetype 1>/dev/null && \
		echo "session.screen0.antialias: true" >> data/init.in

	# Fix broken styles
	ebegin "Fixing backgrounds..."
	for style in "${S}/data/styles/"* ; do
		[[ -f "${style}" ]] || continue
		sed -i -e 's,\([^f]\)bsetroot,\1fbsetroot,' "${style}" \
			|| die "styles sed failed on ${style}"
	done
	eend 0
}

src_compile() {
	export PKG_CONFIG_PATH="${EPREFIX}"/usr/X11R6/lib/pkgconfig:"${EPREFIX}"/usr/lib/pkgconfig

	econf \
		$(use_enable nls) \
		$(use_enable xinerama) \
		$(use_enable truetype xft) \
		$(use_enable kde) \
		$(use_enable gnome) \
		$(use_enable imlib imlib2) \
		$(use_enable !disableslit slit ) \
		$(use_enable !disabletoolbar toolbar ) \
		--sysconfdir="${EPREFIX}"/etc/X11/${PN} \
		--with-style="${EPREFIX}"/usr/share/fluxbox/styles/Emerge \
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
	make DESTDIR="${D}" install || die "make install failed"
	dodoc README* AUTHORS TODO* ChangeLog NEWS

	dodir /usr/share/xsessions
	insinto /usr/share/xsessions
	doins "${FILESDIR}/${PN}.desktop"

	dodir /etc/X11/Sessions
	echo "${EPREFIX}/usr/bin/startfluxbox" > "${ED}/etc/X11/Sessions/fluxbox"
	fperms a+x /etc/X11/Sessions/fluxbox

	dodir /usr/share/fluxbox/menu.d

	# Styles menu framework
	dodir /usr/share/fluxbox/menu.d/styles
	insinto /usr/share/fluxbox/menu.d/styles
	doins "${FILESDIR}/styles-menu-fluxbox" || die
	doins "${FILESDIR}/styles-menu-commonbox" || die
	doins "${FILESDIR}/styles-menu-user" || die
}

pkg_postinst() {
	einfo "As of fluxbox 0.9.10-r3, we are using an improved layout for"
	einfo "styles to avoid problems with huge menus. Use the following"
	einfo "in the menu for your menu styles section:"
	echo
	einfo "    [submenu] (Styles) {Select a Style}"
	einfo "        [include] (${EPREFIX}/usr/share/fluxbox/menu.d/styles/)"
	einfo "    [end]"
	echo
	einfo "If you use fluxbox-generate_menu or the default global fluxbox"
	einfo "menu file, this will already be present."
	echo
	einfo "Note that menumaker and similar utilities do *not* support"
	einfo "this out of the box."
	echo
	einfo "As of fluxbox 0.9.14_pre1, Fluxbox uses XFT for font rendering. If"
	einfo "you experience font problems, try tinkering with your theme files."
	einfo "You can check the validity of a font name using:"
	echo
	einfo "    XFT_DEBUG=1 xfd -fa 'whatever-12:bold'"
	echo
	einfo "The slow startup issues in previous versions should now be fixed;"
	einfo "if you still encounter problems, please report bugs upstream."
}

