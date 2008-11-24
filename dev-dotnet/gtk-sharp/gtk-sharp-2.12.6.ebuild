# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/gtk-sharp/gtk-sharp-2.12.6.ebuild,v 1.2 2008/11/23 21:02:03 loki_val Exp $

EAPI="prefix 1"

inherit eutils mono autotools

DESCRIPTION="Gtk# is a C# language binding for the GTK2 toolkit and GNOME libraries"
HOMEPAGE="http://gtk-sharp.sourceforge.net/"
SRC_URI="mirror://gnome/sources/${PN}/${PV%.*}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="+glade"

RDEPEND=">=dev-lang/mono-1.1.9
		glade? ( >=gnome-base/libglade-2.3.6 )
		 >=x11-libs/gtk+-2.12
		!<dev-dotnet/glade-sharp-9999"
DEPEND="${RDEPEND}
		>=dev-util/pkgconfig-0.19
		>=dev-util/monodoc-1.1.8"

RESTRICT="test"
MAKEOPTS="${MAKEOPTS} -j1"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Upstream bug #421063
	epatch "${FILESDIR}/${PN}-2.12.0-parallelmake.patch"
	epatch "${FILESDIR}/${PN}-2.12.0-doc-parallelmake.patch"
	# Upstream bug #443174
	epatch "${FILESDIR}/${PN}-2.12.0-respect-choices.patch"
	# Upstream bug #443180
	epatch "${FILESDIR}/${PN}-2.12.0-noautomagic.patch"

	# Upsteram bug #443175
	sed -i -e ':^CFLAGS=:d' "${S}/configure.in"

	# disable building of samples (#16015)
	sed -i -e "s:sample::" Makefile.am

	eautoreconf
}

src_compile() {
	econf $(use_enable glade) || die "configure failed"
	LANG=C emake || die
}

src_install () {
	emake DESTDIR="${D}" install || die

	dodoc README* ChangeLog
}
