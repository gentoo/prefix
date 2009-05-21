# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libwnck/libwnck-2.26.1.ebuild,v 1.1 2009/05/04 22:35:25 eva Exp $

inherit gnome2 eutils autotools

DESCRIPTION="A window navigation construction kit"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="doc"

RDEPEND=">=x11-libs/gtk+-2.11.3
	>=dev-libs/glib-2.16.0
	>=x11-libs/startup-notification-0.4
	x11-libs/libX11
	x11-libs/libXres
	x11-libs/libXext"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/pkgconfig-0.9
	>=dev-util/intltool-0.40
	doc? ( >=dev-util/gtk-doc-1.9 )"

DOCS="AUTHORS ChangeLog HACKING NEWS README"

src_unpack() {
	gnome2_src_unpack

	# eautreconf requires a gtkdocize ran before it, otherwise the variable
	# $GTKDOC_REBASE is not set in the Makefiles and causes failure.
	gtkdocize

	eautoreconf # need new libtool for interix
}
