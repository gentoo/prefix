# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/gtk-sharp/gtk-sharp-2.10.2.ebuild,v 1.3 2009/01/06 12:51:21 loki_val Exp $

inherit eutils mono autotools

DESCRIPTION="Gtk# is a C# language binding for the GTK2 toolkit and GNOME libraries"
HOMEPAGE="http://gtk-sharp.sourceforge.net/"
SRC_URI="mirror://gnome/sources/${PN}/${PV%.*}/${P}.tar.gz
		 mirror://gentoo/${PN}-2.10.0-configurable.diff.gz"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="doc"

RDEPEND=">=dev-lang/mono-1.1.9
	>=x11-libs/gtk+-2.10
	!dev-dotnet/atk-sharp
	!dev-dotnet/gdk-sharp
	!dev-dotnet/glib-sharp
	!dev-dotnet/gtk-dotnet-sharp
	!dev-dotnet/gtk-sharp-gapi
	!dev-dotnet/pango-sharp
	"
DEPEND="${RDEPEND}
		>=dev-util/pkgconfig-0.19
		doc? ( >=virtual/monodoc-1.1.8 )"

RESTRICT="test"
MAKEOPTS="${MAKEOPTS} -j1"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${WORKDIR}/${PN}-2.10.0-configurable.diff"

	sed -i -e ':^CFLAGS=:d' "${S}/configure.in"

	# Fix up pkgconfig entries
	sed -i -e 's:^prefix.*:prefix=@prefix@:' \
	       -e 's:^libdir.*:libdir=@libdir@:' \
	"${S}"/*/*.pc.in || die

	eautoreconf

	# disable building of samples (#16015)
	sed -i -e "s:sample::" Makefile.in
}

src_compile() {
	econf --disable-glade || die "configure failed"
	LANG=C emake || die
}

src_install () {
	emake GACUTIL_FLAGS="/root "${ED}"/usr/$(get_libdir) /gacdir /usr/$(get_libdir) /package ${PN}-2.0" \
	      DESTDIR="${D}" install || die

	dodoc README* ChangeLog
}
