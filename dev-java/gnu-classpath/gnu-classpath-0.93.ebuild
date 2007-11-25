# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/gnu-classpath/gnu-classpath-0.93.ebuild,v 1.5 2007/07/11 19:58:37 mr_bones_ Exp $

EAPI="prefix"

inherit autotools eutils flag-o-matic multilib

MY_P=${P/gnu-/}
DESCRIPTION="Free core class libraries for use with virtual machines and compilers for the Java programming language"
SRC_URI="mirror://gnu/classpath/${MY_P}.tar.gz"
HOMEPAGE="http://www.gnu.org/software/classpath"

LICENSE="GPL-2-with-linking-exception"
SLOT="0.93"
KEYWORDS="~amd64 ~x86 ~x86-macos"

# Add the doc use flag after the upstream build system is improved
# See their bug 24025

IUSE="alsa cairo debug dssi examples gconf gtk nsplugin xml"

GTK_DEPS="
		>=x11-libs/gtk+-2.8
		>=dev-libs/glib-2.0
		|| (
				x11-libs/libICE
				x11-libs/libSM
				x11-libs/libX11
				x11-libs/libXtst
		)
		cairo? ( >=x11-libs/cairo-0.5.0 )
"

RDEPEND="alsa? ( media-libs/alsa-lib )
		dssi? ( >=media-libs/dssi-0.9 )
		gconf? ( gnome-base/gconf )
		gtk? ( ${GTK_DEPS} )
		nsplugin? (
			${GTK_DEPS}
			|| (
				www-client/mozilla-firefox
				net-libs/xulrunner
				www-client/seamonkey
			)
		)
		xml? ( >=dev-libs/libxml2-2.6.8 >=dev-libs/libxslt-1.1.11 )"

DEPEND="app-arch/zip
		>=dev-java/jikes-1.22-r13
		gtk? ( || (
					x11-libs/libXrender
					x11-proto/xextproto
					x11-proto/xproto
				)
			)
		${REPEND}"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/0.93-nsplugin.patch"
	eautoconf
}

src_compile() {
	unset CLASSPATH JAVA_HOME
	# We want to force use of jikes, because it is the only way to build
	# classpath without requiring some sort of Java already available, ie ecj
	# requires a runtime and gcj already has a bundled version.

	# https://bugs.gentoo.org/show_bug.cgi?id=163801
	# for jikes-bin
	local compiler="--with-jikes="${EPREFIX}"/usr/bin/jikes-bin"

	# Now this detects fastjar automatically and some people have broken
	# wrappers in /usr/bin by eselect-compiler. Unfortunately
	# --without-fastjar does not seem to work.
	# http://bugs.gentoo.org/show_bug.cgi?id=135688

	# The plugin needs the gtk peer or the build fails
	# http://gcc.gnu.org/bugzilla/show_bug.cgi?id=27923
	local myconf
	if use nsplugin; then
		myconf="--enable-gtk-peer"
	else
		myconf="$(use_enable gtk gtk-peer)"
	fi

	# TODO: check head and report upstream. If gconf is not installed it
	# it should set this automatically to file
	use gconf || myconf="${myconf} --enable-default-preferences-peer=file"

	# https://bugs.gentoo.org/show_bug.cgi?id=168800
	# http://gcc.gnu.org/bugzilla/show_bug.cgi?id=31002
	replace-flags -O3 -O2

	# don't use econf, because it ends up putting things under /usr, which may
	# collide with other slots of classpath
	./configure ${compiler} \
		$(use_enable alsa) \
		$(use_enable cairo gtk-cairo) \
		$(use_enable debug ) \
		$(use_enable examples) \
		$(use_enable gconf gconf-peer) \
		$(use_enable nsplugin plugin) \
		$(use_enable xml xmlj) \
		$(use_enable dssi ) \
		${myconf} \
		--enable-jni \
		--disable-dependency-tracking \
		--host=${CHOST} \
		--prefix="${EPREFIX}"/opt/${PN}-${SLOT} \
		|| die "configure failed"
	# disabled for now... see above.
	#		$(use_with   doc   gjdoc) \

	emake || die "make failed"
}

src_install() {
	emake DESTDIR=${D} install || die "einstall failed"
	dodoc AUTHORS BUGS ChangeLog* HACKING NEWS README THANKYOU TODO || die
}
