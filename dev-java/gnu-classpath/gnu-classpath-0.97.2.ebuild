# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/gnu-classpath/gnu-classpath-0.97.2.ebuild,v 1.5 2009/09/18 16:23:22 tove Exp $

EAPI=1

inherit eutils flag-o-matic multilib

MY_P=${P/gnu-/}
DESCRIPTION="Free core class libraries for use with virtual machines and compilers for the Java language"
SRC_URI="mirror://gnu/classpath/${MY_P}.tar.gz"
HOMEPAGE="http://www.gnu.org/software/classpath"

LICENSE="GPL-2-with-linking-exception"
SLOT="0.97"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

IUSE="alsa debug doc dssi examples gconf gtk gstreamer nsplugin qt4 xml"

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
			x11-libs/libXrandr
			x11-libs/libXrender
			x11-libs/libXtst
			x11-libs/pango
		)
		nsplugin? (
			>=x11-libs/gtk+-2.8
			|| (
				=www-client/mozilla-firefox-2*
				=net-libs/xulrunner-1.8*
				=www-client/seamonkey-1*
				=www-client/seamonkey-bin-1*
				=www-client/mozilla-firefox-bin-2*
			)
		)
		qt4? ( x11-libs/qt-gui:4 )
		xml? ( >=dev-libs/libxml2-2.6.8 >=dev-libs/libxslt-1.1.11 )
		gstreamer? (
			>=media-libs/gstreamer-0.10.10
			>=media-libs/gst-plugins-base-0.10.10
			dev-libs/glib
		)
		sys-apps/file"

DEPEND="app-arch/zip
		dev-java/eclipse-ecj:3.3
		gtk? (
			x11-proto/xextproto
			x11-proto/xproto
		)
		${RDEPEND}"

S=${WORKDIR}/${MY_P}

src_compile() {
	export JAVAC="${EPREFIX}/usr/bin/ecj-3.3 -nowarn"

	# don't use econf, because it ends up putting things under /usr, which may
	# collide with other slots of classpath
	./configure \
		$(use_enable alsa) \
		$(use_enable debug ) \
		$(use_enable examples) \
		$(use_enable gconf gconf-peer) \
		$(use_enable gtk gtk-peer) \
		$(use_enable gstreamer gstreamer-peer) \
		$(use_enable nsplugin plugin) \
		$(use_enable qt4 qt-peer) \
		$(use_enable xml xmlj) \
		$(use_enable dssi ) \
		--enable-jni \
		--disable-dependency-tracking \
		--disable-Werror \
		--host=${CHOST} \
		--prefix="${EPREFIX}"/opt/${PN}-${SLOT} \
		--with-ecj-jar="${EPREFIX}"/usr/share/eclipse-ecj-3.3/lib/ecj.jar \
		--with-vm=java \
		|| die "configure failed"
	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS BUGS ChangeLog* HACKING NEWS README THANKYOU TODO || die
}
