# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/gnu-classpath/gnu-classpath-0.97.ebuild,v 1.2 2008/04/08 16:20:27 armin76 Exp $

inherit eutils flag-o-matic multilib java-pkg-2

MY_P=${P/gnu-/}
DESCRIPTION="Free core class libraries for use with virtual machines and compilers for the Java programming language"
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
		qt4? ( >=x11-libs/qt-4.1.0 )
		xml? ( >=dev-libs/libxml2-2.6.8 >=dev-libs/libxslt-1.1.11 )
		gstreamer? (
			>=media-libs/gstreamer-0.10.10
			>=media-libs/gst-plugins-base-0.10.10
			dev-libs/glib
		)
		sys-apps/file"

DEPEND="app-arch/zip
		>=virtual/jdk-1.6.0
		gtk? (
			x11-proto/xextproto
			x11-proto/xproto
		)
		${REPEND}"

S=${WORKDIR}/${MY_P}

src_compile() {
	# Upstreams sets proper -source and -target
	unset JAVACFLAGS

	# Forcing 1.6 for now because of this but perhaps should come up with
	# something smart

	#if [[ ( ${GENTOO_VM} == sun-jdk-1.5 || ${GENTOO_VM} == ibm-jdk-bin-1.5 ) \
	#	&& ${GENTOO_COMPILER} == javac ]]; then
	#	eerror "javac from ${GENTOO_VM} is not able to compile"
	#	eerror "${CATEGORY}/${P}, use ecj or sun-jdk-1.6 instead"
	#	die "Unusable JDK + compiler combination"
	#fi

	# don't use econf, because it ends up putting things under /usr, which may
	# collide with other slots of classpath
	./configure ${compiler} \
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
		${myconf} \
		--enable-jni \
		--disable-dependency-tracking \
		--disable-Werror \
		--host=${CHOST} \
		--prefix="${EPREFIX}"/opt/${PN}-${SLOT} \
		|| die "configure failed"
	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS BUGS ChangeLog* HACKING NEWS README THANKYOU TODO || die
}
