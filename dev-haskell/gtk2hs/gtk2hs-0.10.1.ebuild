# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-haskell/gtk2hs/gtk2hs-0.10.1.ebuild,v 1.4 2010/07/13 11:00:26 slyfox Exp $

EAPI="2"

inherit base eutils autotools ghc-package multilib toolchain-funcs versionator

DESCRIPTION="A GUI Library for Haskell based on Gtk+"
HOMEPAGE="http://haskell.org/gtk2hs/"

SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"

KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

IUSE="doc profile glade gnome opengl svg"

RDEPEND=">=dev-lang/ghc-6.6
		dev-haskell/mtl[doc?]
		x11-libs/gtk+:2
		glade? ( gnome-base/libglade )
		gnome? ( gnome-base/libglade
				>=x11-libs/gtksourceview-2.2
				gnome-base/gconf )
		svg?   ( gnome-base/librsvg )
		opengl? ( x11-libs/gtkglext )"

DEPEND="${RDEPEND}
		doc? ( >=dev-haskell/haddock-2.4.1 )
		dev-util/pkgconfig"

MY_P="${P/%_rc*}"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	epatch "${FILESDIR}/gtk2hs-0.10.1-ghc-6.12-packages.patch"
	epatch "${FILESDIR}/gtk2hs-0.10.1-ghc-6.12-c2hs.patch"
	cd "${S}"

	# In GHC 6.12.2, qualified imports is now an error
	sed -i -e "s/Map.findWithDefault, empty/findWithDefault, empty/" \
		tools/c2hs/base/syms/Attributes.hs \
		|| die "Can't remove qualified import"

	eautoreconf
}

src_configure() {
	econf \
		--enable-gtk \
		--enable-packager-mode \
		$(version_is_at_least "4.2" "$(gcc-version)" && \
			echo --disable-split-objs) \
		$(has_version '>=x11-libs/gtk+-2.8' && echo --enable-cairo) \
		$(use glade || use gnome && echo --enable-libglade) \
		$(use_enable gnome gconf) \
		$(use_enable gnome gtksourceview2) \
		$(use_enable svg svg) \
		$(use_enable opengl opengl) \
		--disable-seamonkey \
		--disable-firefox \
		--disable-xulrunner \
		$(use_enable doc docs) \
		$(use_enable profile profiling) \
		|| die "Configure failed"
}

src_compile() {
	emake -j1 || die "emake failed"
}

src_install() {

	make install \
		DESTDIR="${D}" \
		htmldir="${EPREFIX}/usr/share/doc/${PF}/html" \
		haddockifacedir="${EPREFIX}/usr/share/doc/${PF}" \
		|| die "Make install failed"

	# arrange for the packages to be registered
	ghc-setup-pkg \
		"${ED}/usr/$(get_libdir)/gtk2hs/glib.package.conf" \
		$(has_version '>=x11-libs/gtk+-2.8' && echo \
			"${ED}/usr/$(get_libdir)/gtk2hs/cairo.package.conf") \
		"${ED}/usr/$(get_libdir)/gtk2hs/gtk.package.conf" \
		"${ED}/usr/$(get_libdir)/gtk2hs/soegtk.package.conf" \
		$(use glade || use gnome && echo \
			"${ED}/usr/$(get_libdir)/gtk2hs/glade.package.conf") \
		$(use gnome && echo \
			"${ED}/usr/$(get_libdir)/gtk2hs/gconf.package.conf" \
			"${ED}/usr/$(get_libdir)/gtk2hs/gtksourceview2.package.conf" ) \
		$(use svg && echo \
			"${ED}/usr/$(get_libdir)/gtk2hs/svgcairo.package.conf") \
		$(use opengl && echo \
			"${ED}/usr/$(get_libdir)/gtk2hs/gtkglext.package.conf")
	ghc-install-pkg
}
