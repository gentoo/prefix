# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/wxGTK/wxGTK-2.8.9.1-r3.ebuild,v 1.8 2009/02/15 15:19:44 ranger Exp $

EAPI=2

inherit eutils versionator flag-o-matic

DESCRIPTION="GTK+ version of wxWidgets, a cross-platform C++ GUI toolkit."
HOMEPAGE="http://wxwidgets.org/"

BASE_PV="$(get_version_component_range 1-3)"
BASE_P="${PN}-${BASE_PV}"

# we use the wxPython tarballs because they include the full wxGTK sources and
# docs, and are released more frequently than wxGTK.
SRC_URI="mirror://sourceforge/wxpython/wxPython-src-${PV}.tar.bz2"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="X doc debug gnome gstreamer odbc opengl pch sdl"

RDEPEND="
	dev-libs/expat
	odbc?   ( dev-db/unixODBC )
	sdl?    ( media-libs/libsdl )
	X?  (
		>=x11-libs/gtk+-2.4
		>=dev-libs/glib-2.4
		media-libs/jpeg
		media-libs/tiff
		x11-libs/libSM
		x11-libs/libXinerama
		x11-libs/libXxf86vm
		gnome?  ( gnome-base/libgnomeprintui )
		gstreamer? ( >=media-libs/gstreamer-0.10 )
		opengl? ( virtual/opengl )
		)"

DEPEND="${RDEPEND}
		dev-util/pkgconfig
		X?  (
			x11-proto/xproto
			x11-proto/xineramaproto
			x11-proto/xf86vidmodeproto
			)"

PDEPEND=">=app-admin/eselect-wxwidgets-0.7"

SLOT="2.8"
LICENSE="wxWinLL-3
		GPL-2
		odbc?	( LGPL-2 )
		doc?	( wxWinFDL-3 )"

S="${WORKDIR}/wxPython-src-${PV}"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.6.3-unicode-odbc.patch
	epatch "${FILESDIR}"/${PN}-2.8.8-collision.patch
	epatch "${FILESDIR}"/${PN}-2.8.6-wxrc_link_fix.patch
	epatch "${FILESDIR}"/${PN}-2.8.7-mmedia.patch			# Bug #174874
	epatch "${FILESDIR}"/${PN}-2.8.9-dont-touch-my-bools.patch	# Bug #245973
}

src_configure() {
	local myconf

	append-flags -fno-strict-aliasing

	# X independent options
	myconf="--enable-compat26
			--enable-shared
			--enable-unicode
			--with-regex=builtin
			--with-zlib=sys
			--with-expat
			$(use_enable debug)
			$(use_enable pch precomp-headers)
			$(use_with sdl)
			$(use_with odbc)"

	# wxGTK options
	#   --enable-graphics_ctx - needed for webkit, editra
	#   --without-gnomevfs - bug #203389

	use X && \
		myconf="${myconf}
			--enable-graphics_ctx
			--enable-gui
			--with-libpng
			--with-libxpm
			--with-libjpeg
			--with-libtiff
			$(use_enable gstreamer mediactrl)
			$(use_enable opengl)
			$(use_with opengl)
			$(use_with gnome gnomeprint)
			--without-gnomevfs"

	# wxBase options
	use X || \
		myconf="${myconf}
			--disable-gui"

	mkdir "${S}"/wxgtk_build
	cd "${S}"/wxgtk_build

	ECONF_SOURCE="${S}" econf ${myconf} || die "configure failed."
}

src_compile() {
	cd "${S}"/wxgtk_build

	emake || die "make failed."

	if [[ -d contrib/src ]]; then
		cd contrib/src
		emake || die "make contrib failed."
	fi
}

src_install() {
	cd "${S}"/wxgtk_build

	emake DESTDIR="${D}" install || die "install failed."

	if [[ -d contrib/src ]]; then
		cd contrib/src
		emake DESTDIR="${D}" install || die "install contrib failed."
	fi

	cd "${S}"/docs
	dodoc changes.txt readme.txt todo30.txt
	newdoc base/readme.txt base_readme.txt
	newdoc gtk/readme.txt gtk_readme.txt

	if use doc; then
		dohtml -r "${S}"/docs/html/*
	fi

	# We don't want this
	rm "${ED}"usr/share/locale/it/LC_MESSAGES/wxmsw.mo
}

pkg_postinst() {
	has_version app-admin/eselect-wxwidgets \
		&& eselect wxwidgets update
}

pkg_postrm() {
	has_version app-admin/eselect-wxwidgets \
		&& eselect wxwidgets update
}
