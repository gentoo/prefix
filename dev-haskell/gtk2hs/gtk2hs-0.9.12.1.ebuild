# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-haskell/gtk2hs/gtk2hs-0.9.12.1.ebuild,v 1.13 2010/06/28 14:28:37 ssuominen Exp $

inherit base eutils ghc-package multilib toolchain-funcs versionator

DESCRIPTION="A GUI Library for Haskell based on Gtk+"
HOMEPAGE="http://haskell.org/gtk2hs/"
SRC_URI="mirror://sourceforge/gtk2hs/${P}.tar.gz"
LICENSE="LGPL-2.1"
SLOT="0"

KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

IUSE="doc glade gnome opengl svg profile"

RDEPEND=">=dev-lang/ghc-6.4
		dev-haskell/mtl
		>=x11-libs/gtk+-2
		glade? ( >=gnome-base/libglade-2 )
		gnome? ( >=gnome-base/libglade-2
				<x11-libs/gtksourceview-2.0
				>=gnome-base/gconf-2 )
		svg?   ( >=gnome-base/librsvg-2.16 )
		opengl? ( x11-libs/gtkglext )"

DEPEND="${RDEPEND}
		doc? ( >=dev-haskell/haddock-0.8 )
		dev-util/pkgconfig"

src_unpack() {
	unpack ${A}

	sed -i -e '\|docs/reference/haddock.js|d' \
		   -e '/$(foreach LETTER,/,+1 d' \
		   -e '\|\tdocs/reference/gtk2hs.haddock| s/\\//' \
		   "${S}/Makefile.in"

	cd "${S}"
	epatch "${FILESDIR}/${P}-librsvg-2.22.3.patch"
}

src_compile() {
	econf \
		--enable-packager-mode \
		$(version_is_at_least "4.2" "$(gcc-version)" && \
			echo --disable-split-objs) \
		$(has_version '>=x11-libs/gtk+-2.8' && echo --enable-cairo) \
		$(use glade || use gnome && echo --enable-libglade) \
		$(use_enable gnome gconf) \
		$(use_enable gnome sourceview) \
		$(use_enable svg svg) \
		$(use_enable opengl opengl) \
		--disable-firefox \
		--disable-seamonkey \
		--disable-xulrunner \
		$(use_enable doc docs) \
		$(use_enable profile profiling) \
		|| die "Configure failed"

	# parallel build doesn't work, so specify -j1
	emake -j1 || die "Make failed"
}

src_install() {

	make install \
		DESTDIR="${D}" \
		htmldir="${EPREFIX}/usr/share/doc/${PF}/html" \
		haddockifacedir="${EPREFIX}/usr/share/doc/${PF}" \
		|| die "Make install failed"

	# for some reason it creates the doc dir even if it is configured
	# to not generate docs, so lets remove the empty dirs in that case
	# (and lets be cautious and only remove them if they're empty)
	if ! use doc; then
		rmdir "${ED}/usr/share/doc/${PF}/html"
		rmdir "${ED}/usr/share/doc/${PF}"
		rmdir "${ED}/usr/share/doc"
		rmdir "${ED}/usr/share"
	fi

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
			"${ED}/usr/$(get_libdir)/gtk2hs/sourceview.package.conf" ) \
		$(use svg && echo \
			"${ED}/usr/$(get_libdir)/gtk2hs/svgcairo.package.conf") \
		$(use opengl && echo \
			"${ED}/usr/$(get_libdir)/gtk2hs/gtkglext.package.conf")
	ghc-install-pkg
}
