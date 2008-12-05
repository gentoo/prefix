# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/gtk-sharp/gtk-sharp-2.12.7_pre20081204.ebuild,v 1.1 2008/12/04 23:51:49 loki_val Exp $

EAPI="prefix 2"

inherit eutils mono autotools

REQUIRE_GTK=2.12

DESCRIPTION="Gtk# is a C# language binding for the GTK2 toolkit and GNOME libraries"
HOMEPAGE="http://gtk-sharp.sourceforge.net/"
SRC_URI="http://dev.gentoo.org/~loki_val/${P}.tar.gz"
#SRC_URI="mirror://gentooe/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="+glade doc"

RDEPEND=">=dev-lang/mono-1.1.9
		glade? ( >=gnome-base/libglade-2.3.6 )
		 >=x11-libs/gtk+-${REQUIRE_GTK}
		!dev-dotnet/glade-sharp"
DEPEND="${RDEPEND}
		>=dev-util/pkgconfig-0.19
		doc? ( >=dev-util/monodoc-1.1.8 )"

RESTRICT="test"

S="${WORKDIR}/${PN}"

bootstrap() {
	srcdir=.
	GTK_SHARP_VERSION=${PV%_*}
	ASSEMBLY_VERSION=${REQUIRE_GTK}.0.0
	POLICY_VERSIONS="2.4 2.6 2.8 2.10"
	GTK_REQUIRED_VERSION=${REQUIRE_GTK}.0
	VERSIONCSDEFINES="-define:GTK_SHARP_2_6 -define:GTK_SHARP_2_8 -define:GTK_SHARP_2_10 -define:GTK_SHARP_2_12"
	VERSIONCFLAGS="-DGTK_SHARP_2_6 -DGTK_SHARP_2_8 -DGTK_SHARP_2_10 -DGTK_SHARP_2_12"
	GTK_API_TAG=${REQUIRE_GTK}
	sed -e "s/@GTK_SHARP_VERSION@/$GTK_SHARP_VERSION/" \
	    -e "s/@GTK_REQUIRED_VERSION@/$GTK_REQUIRED_VERSION/" \
	    -e "s/@VERSIONCSDEFINES@/$VERSIONCSDEFINES/" \
	    -e "s/@VERSIONCFLAGS@/$VERSIONCFLAGS/" \
	    -e "s/@POLICY_VERSIONS@/$POLICY_VERSIONS/" \
	    -e "s/@ASSEMBLY_VERSION@/$ASSEMBLY_VERSION/" $srcdir/configure.in.in > $srcdir/configure.in

	ln -f $srcdir/pango/pango-api-$GTK_API_TAG.raw $srcdir/pango/pango-api.raw
	ln -f $srcdir/atk/atk-api-$GTK_API_TAG.raw $srcdir/atk/atk-api.raw
	ln -f $srcdir/gdk/gdk-api-$GTK_API_TAG.raw $srcdir/gdk/gdk-api.raw
	ln -f $srcdir/gtk/gtk-api-$GTK_API_TAG.raw $srcdir/gtk/gtk-api.raw
	ln -f $srcdir/glade/glade-api-$GTK_API_TAG.raw $srcdir/glade/glade-api.raw
}


src_prepare() {

	ebegin "Bootstrapping..."
	bootstrap
	eend $?
	#Upstream: https://bugzilla.novell.com/show_bug.cgi?id=$bugno

	# Upstream bug #421063
	epatch "${FILESDIR}/${PN}-2.12.0-parallelmake.patch"
	epatch "${FILESDIR}/${PN}-2.12.0-doc-parallelmake.patch"

	# Upstream bug #443180
	epatch "${FILESDIR}/${PN}-2.12.0-noautomagic.patch"

	# Upstream bug #443175
	sed -i -e ':^CFLAGS=:d' "${S}/configure.in"

	# disable building of samples (#16015)
	sed -i -e "s:sample::" Makefile.am

	eautoreconf
}

src_configure() {
	econf $(use_enable doc monodoc) $(use_enable glade) || die "configure failed"
}

src_compile() {
	LANG=C emake || die
}

src_install () {
	emake DESTDIR="${D}" install || die

	dodoc README* ChangeLog
}
