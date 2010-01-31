# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/poppler-glib/poppler-glib-0.10.7.ebuild,v 1.8 2009/08/09 11:55:00 nixnut Exp $

EAPI=2

POPPLER_MODULE=glib

inherit poppler flag-o-matic

DESCRIPTION="Glib bindings for poppler"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="+cairo"

# The Cairo renderer represents a superset of the splash renderer.
# We could also have a gtk use-flag for the interface to gdk-pixbuf, but that wouldn't
# make sense for us, because:
# 1. Every app that is ok with only [cairo] is already depending on gtk+:2 :
#	media-gfx/inkscape
#	app-text/evince
# 2. Cairo is a dependency of gtk+:2
# 3. gdk and gdk-pixbuf is the old way of doing things. Everybody is hot for cairo.
# 4. In fact, the only app that's ok with [-cairo,-gtk] is app-misc/tracker.

RDEPEND="
	~dev-libs/poppler-${PV}
	>=dev-libs/glib-2.16
	cairo? (
		>=x11-libs/cairo-1.8.2
		>=x11-libs/gtk+-2.14.0:2
	)
	"
DEPEND="
	${RDEPEND}
	dev-util/pkgconfig
	"

pkg_setup() {
	POPPLER_CONF="$(use_enable cairo cairo-output) $(use_enable cairo gdk) $(use_enable cairo splash-output)"
	POPPLER_PKGCONFIG=( poppler-glib.pc cairo=poppler-cairo.pc )
	if ! use cairo
	then
		export CPPFLAGS="${CPPFLAGS} -DHAVE_SPLASH" poppler_src_compile
	fi
}

src_prepare() {
	poppler_src_prepare
	sed -i	\
		-e 's:reference::'	\
		-e 's:demo::'		\
		glib/Makefile.in || die "Fixing glib Makefile.in failed"
	use cairo || { sed -i -e 's:gdk-2.0 gdk-pixbuf-2.0 ::' poppler-glib.pc.in || die "Sedding poppler-glib.pc.in failed" ; }
}

src_compile() {
	use cairo && POPPLER_MODULE_S="${S}/poppler" poppler_src_compile libpoppler-cairo.la
	poppler_src_compile
}
