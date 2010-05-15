# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/gnu-classpath/gnu-classpath-0.97.2-r1.ebuild,v 1.4 2010/03/25 13:15:47 caster Exp $

EAPI=1

inherit eutils multilib java-pkg-2

MY_P=${P/gnu-/}
DESCRIPTION="Free core class libraries for use with virtual machines and compilers for the Java language"
SRC_URI="mirror://gnu/classpath/${MY_P}.tar.gz"
HOMEPAGE="http://www.gnu.org/software/classpath"

LICENSE="GPL-2-with-linking-exception"
SLOT="0.97"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

IUSE="alsa debug doc dssi examples gconf gtk gstreamer qt4 xml"

RDEPEND="alsa? ( media-libs/alsa-lib )
		doc? ( >=dev-java/gjdoc-0.7.8 )
		dssi? ( >=media-libs/dssi-0.9 )
		gconf? (
			>=gnome-base/gconf-2.6.0
			>=x11-libs/gtk+-2.8
		)
		gtk? (
			>=x11-libs/gtk+-2.8
			>=dev-libs/glib-2.0
			media-libs/freetype
			>=x11-libs/cairo-1.1.9
			x11-libs/pango
			x11-libs/libICE
			x11-libs/libSM
			x11-libs/libXrandr
			x11-libs/libXrender
			x11-libs/libXtst
			x11-libs/libX11
		)
		qt4? ( x11-libs/qt-gui:4 )
		xml? ( >=dev-libs/libxml2-2.6.8 >=dev-libs/libxslt-1.1.11 )
		gstreamer? (
			>=media-libs/gstreamer-0.10.10
			>=media-libs/gst-plugins-base-0.10.10
			x11-libs/gtk+
		)
		sys-apps/file"

DEPEND="app-arch/zip
		dev-java/eclipse-ecj:3.5
		gtk? (
			x11-libs/libXrender
			|| ( >=x11-libs/libXtst-1.1.0 <x11-proto/xextproto-7.1 )
			x11-proto/xproto
		)
		${RDEPEND}"

S=${WORKDIR}/${MY_P}

src_compile() {
	export JAVAC="${EPREFIX}/usr/bin/ecj-3.5 -nowarn"

	# build system is passing -J-Xmx768M which ecj however ignores
	# this will make the ecj launcher do it (bug #225921)
	export gjl_java_args="-Xmx768M"

	# don't use econf, because it ends up putting things under /usr, which may
	# collide with other slots of classpath
	./configure \
		$(use_enable alsa) \
		$(use_enable debug ) \
		$(use_enable examples) \
		$(use_enable gconf gconf-peer) \
		$(use_enable gtk gtk-peer) \
		$(use_enable gstreamer gstreamer-peer) \
		$(use_enable qt4 qt-peer) \
		$(use_enable xml xmlj) \
		$(use_enable dssi ) \
		--enable-jni \
		--disable-dependency-tracking \
		--disable-Werror \
		--disable-plugin \
		--host=${CHOST} \
		--prefix="${EPREFIX}"/opt/${PN}-${SLOT} \
		--with-ecj-jar=$(java-pkg_getjar --build-only eclipse-ecj:3.5 ecj.jar) \
		--with-vm=java \
		|| die "configure failed"
	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS BUGS ChangeLog* HACKING NEWS README THANKYOU TODO || die
}
