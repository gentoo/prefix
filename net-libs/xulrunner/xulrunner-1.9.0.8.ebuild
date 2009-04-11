# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/xulrunner/xulrunner-1.9.0.8.ebuild,v 1.8 2009/04/03 10:10:54 armin76 Exp $

WANT_AUTOCONF="2.1"

inherit flag-o-matic toolchain-funcs eutils mozconfig-3 makeedit multilib java-pkg-opt-2 python autotools prefix
PATCH="${P}-patches-0.1"

DESCRIPTION="Mozilla runtime package that can be used to bootstrap XUL+XPCOM applications"
HOMEPAGE="http://developer.mozilla.org/en/docs/XULRunner"
SRC_URI="mirror://gentoo/${P}.tar.bz2
	http://dev.gentoo.org/~armin76/dist/${P}.tar.bz2
	mirror://gentoo/${PATCH}.tar.bz2
	http://dev.gentoo.org/~armin76/dist/${PATCH}.tar.bz2"

KEYWORDS="~amd64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
SLOT="1.9"
LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
IUSE=""

RDEPEND="java? ( >=virtual/jre-1.4 )
	>=sys-devel/binutils-2.16.1
	>=dev-libs/nss-3.12.2
	>=dev-libs/nspr-4.7.3
	>=app-text/hunspell-1.1.9
	>=media-libs/lcms-1.17"

DEPEND="java? ( >=virtual/jdk-1.4 )
	${RDEPEND}
	dev-util/pkgconfig"

S="${WORKDIR}/mozilla"

# Needed by src_compile() and src_install().
# Would do in pkg_setup but that loses the export attribute, they
# become pure shell variables.
export MOZ_CO_PROJECT=xulrunner
export BUILD_OFFICIAL=1
export MOZILLA_OFFICIAL=1

pkg_setup(){
	if ! built_with_use x11-libs/cairo X; then
		eerror "Cairo is not built with X useflag."
		eerror "Please add 'X' to your USE flags, and re-emerge cairo."
		die "Cairo needs X"
	fi

	if ! built_with_use --missing true x11-libs/pango X; then
		eerror "Pango is not built with X useflag."
		eerror "Please add 'X' to your USE flags, and re-emerge pango."
		die "Pango needs X"
	fi
	java-pkg-opt-2_pkg_setup
}

src_unpack() {
	unpack ${A}

	# Apply our patches
	cd "${S}" || die "cd failed"
	EPATCH_SUFFIX="patch" \
	EPATCH_FORCE="yes" \
	epatch "${WORKDIR}"/patch

	epatch "${FILESDIR}"/${PN}-1.9-no_sunstudio.patch # breaks sunstudio
	epatch "${FILESDIR}"/${PN}-1.9-solaris64.patch
	epatch "${FILESDIR}"/${PN}-1.9_beta5-prefix.patch
	eprefixify \
		extensions/java/xpcom/interfaces/org/mozilla/xpcom/Mozilla.java \
		xpcom/build/nsXPCOMPrivate.h \
		xulrunner/installer/Makefile.in \
		xulrunner/app/nsRegisterGREUnix.cpp

	eautoreconf || die "failed  running eautoreconf"

	# We need to re-patch this because autoreconf overwrites it
	epatch "${WORKDIR}"/patch/000_flex-configure-LANG.patch
}

src_compile() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}-1.9"

	####################################
	#
	# mozconfig, CFLAGS and CXXFLAGS setup
	#
	####################################

	mozconfig_init
	mozconfig_config

	MEXTENSIONS="default"
#	if use python; then
#		MEXTENSIONS="${MEXTENSIONS},python/xpcom"
#	fi

	# It doesn't compile on alpha without this LDFLAGS
	use alpha && append-ldflags "-Wl,--no-relax"

	mozconfig_annotate '' --enable-extensions="${MEXTENSIONS}"
	mozconfig_annotate '' --disable-mailnews
	mozconfig_annotate 'broken' --disable-mochitest
	mozconfig_annotate 'broken' --disable-crashreporter
	mozconfig_annotate '' --enable-system-hunspell
	#mozconfig_annotate '' --enable-system-sqlite
	mozconfig_annotate '' --enable-image-encoder=all
	mozconfig_annotate '' --enable-canvas
	#mozconfig_annotate '' --enable-js-binary
	mozconfig_annotate '' --enable-embedding-tests
	mozconfig_annotate '' --with-system-nspr
	mozconfig_annotate '' --with-system-nss
	mozconfig_annotate '' --enable-system-lcms
	mozconfig_annotate '' --with-system-bz2
	# Bug 60668: Galeon doesn't build without oji enabled, so enable it
	# regardless of java setting.
	mozconfig_annotate '' --enable-oji --enable-mathml
	mozconfig_annotate 'places' --enable-storage --enable-places --enable-places_bookmarks
	mozconfig_annotate '' --enable-safe-browsing

	# Other ff-specific settings
	mozconfig_annotate '' --enable-jsd
	mozconfig_annotate '' --enable-xpctools
	mozconfig_annotate '' --with-default-mozilla-five-home="${EPREFIX}"${MOZILLA_FIVE_HOME}

	#disable java
	if ! use java ; then
		mozconfig_annotate '-java' --disable-javaxpcom
	fi

	# Finalize and report settings
	mozconfig_final

	if [[ $(gcc-major-version) -lt 4 ]]; then
		append-cxxflags -fno-stack-protector
	fi

	####################################
	#
	#  Configure and build
	#
	####################################

	CPPFLAGS="${CPPFLAGS} -DARON_WAS_HERE" \
	CC="$(tc-getCC)" CXX="$(tc-getCXX)" LD="$(tc-getLD)" \
	econf || die

	# It would be great if we could pass these in via CPPFLAGS or CFLAGS prior
	# to econf, but the quotes cause configure to fail.
	sed -i -e \
		's|-DARON_WAS_HERE|-DGENTOO_NSPLUGINS_DIR=\\\"${EPREFIX}/usr/'"$(get_libdir)"'/nsplugins\\\" -DGENTOO_NSBROWSER_PLUGINS_DIR=\\\"${EPREFIX}/usr/'"$(get_libdir)"'/nsbrowser/plugins\\\"|' \
		"${S}"/config/autoconf.mk \
		"${S}"/toolkit/content/buildconfig.html

	emake || die "emake failed"
}

src_install() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}-1.9"

	emake DESTDIR="${D}" install || die "emake install failed"

	rm "${ED}"/usr/bin/xulrunner

	dodir /usr/bin
	dosym ${MOZILLA_FIVE_HOME}/xulrunner /usr/bin/xulrunner-1.9

	# Add vendor
	echo "pref(\"general.useragent.vendor\",\"Gentoo\");" \
		>> "${ED}"${MOZILLA_FIVE_HOME}/defaults/pref/vendor.js

	if use java ; then
	    java-pkg_regjar "${ED}"${MOZILLA_FIVE_HOME}/javaxpcom.jar
	    java-pkg_regjar "${ED}"${MOZILLA_FIVE_HOME}/sdk/lib/MozillaGlue.jar
	    java-pkg_regjar "${ED}"${MOZILLA_FIVE_HOME}/sdk/lib/MozillaInterfaces.jar
	fi
}
