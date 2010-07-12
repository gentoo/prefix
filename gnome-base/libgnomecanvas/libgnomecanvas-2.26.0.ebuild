# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libgnomecanvas/libgnomecanvas-2.26.0.ebuild,v 1.9 2010/01/16 17:17:18 armin76 Exp $

inherit virtualx gnome2 autotools

DESCRIPTION="The Gnome 2 Canvas library"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc"

# gtk+ raised to fix gail dependency
RDEPEND=">=x11-libs/gtk+-2.13
	>=media-libs/libart_lgpl-2.3.8
	>=x11-libs/pango-1.0.1
	>=gnome-base/libglade-2"

DEPEND="${RDEPEND}
	>=dev-lang/perl-5
	sys-devel/gettext
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.18
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README"

src_unpack() {
	gnome2_src_unpack

	# eautreconf requires a gtkdocize ran before it, otherwise the variable
	# $GTKDOC_REBASE is not set in the Makefiles and causes failure.
	# see also bug #280812
	gtkdocize

	eautoreconf # need new libtool for interix
}

src_test() {
	Xmake check || die "Test phase failed"
}
