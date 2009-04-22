# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/poppler-bindings/poppler-bindings-0.10.5-r1.ebuild,v 1.5 2009/04/21 18:55:26 klausman Exp $

EAPI=2

#Inherit qt3 to get QTDIR even if the env file has not yet been sourced.

inherit qt3 autotools eutils multilib

MY_P=${P/-bindings/}
DESCRIPTION="rendering bindings for GUI toolkits for poppler"
HOMEPAGE="http://poppler.freedesktop.org/"

# Creating the testsuite tarball
# must be done if upstream has added tests since last release.
# can be checked at cgit.freedesktop.org
#
# git clone git://anongit.freedesktop.org/git/poppler/test
# rm -rf test/.git
# tar czf poppler-test-${PV}.tar.gz test

SRC_URI="http://poppler.freedesktop.org/${MY_P}.tar.gz
	test? ( mirror://gentoo/poppler-test-0.9.2.tar.bz2 )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="gtk qt3 cairo qt4 test"

RDEPEND="
	~app-text/poppler-${PV}
	cairo? (
		>=x11-libs/cairo-1.4
		!gtk? (
			>=x11-libs/gtk+-2.8
			>=dev-libs/glib-2.8
		 )
	)
	gtk? (
		>=x11-libs/gtk+-2.8
		>=dev-libs/glib-2.8
	)
	qt3? ( >=x11-libs/qt-3.3:3 )
	qt4? (
		|| (
			( x11-libs/qt-core:4
			  x11-libs/qt-gui:4
			  x11-libs/qt-test:4 )

			=x11-libs/qt-4.3*
		)
	)
	!dev-libs/poppler-qt3
	!dev-libs/poppler-qt4
	!dev-libs/poppler
	!dev-libs/poppler-glib
	!app-text/poppler-utils
	"
DEPEND="
	${RDEPEND}
	dev-util/pkgconfig
	test? ( gtk? ( >=gnome-base/libglade-2 ) )
	"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	if ! { use gtk || use qt3 || use qt4 || use cairo; }
	then
		eerror "You've selected to build no bindings for poppler."
		eerror "Please select at least one of:"
		eerror "gtk, qt3, qt4, cairo"
		die "Please select a toolkit"
	fi
	use test && ewarn "Tests will fail if your locale is unset."
}

src_prepare() {
	epatch "${FILESDIR}/poppler-CVE-2009-1187.patch"
	sed -i \
		-e 's:$(top_builddir)/poppler/libpoppler.la:-lpoppler:'	\
		$(find . -name 'Makefile.am' ) || die "404"
	sed -i \
		-e '/libpoppler_la_LIBADD/,/win32_libs/d'		\
		-e '/libpoppler_la_SOURCES/,/XpdfPluginAPI.cc/d'	\
		-e '/libpoppler.la/d'					\
		-e '/libpoppler_la/d'					\
		poppler/Makefile.am || die "404"

	sed -i \
		-e '/if BUILD_SPLASH_OUTPUT/,/endif/d'			\
		-e '/poppler.pc\t/d'					\
		-e ':$(splash_pc_file):d'				\
		Makefile.am || die "404"
	rm m4/lt*.m4 m4/libtool.m4 || die "rm failed"

	eautoreconf
}

src_configure() {
	# Configure needs help finding qt libs on multilib systems
	export QTLIB="${QTDIR}/$(get_libdir)"
	echo $QTLIB

	[[ ${CHOST} == *-interix* ]] && append-flags -D_REENTRANT

	econf	--disable-utils						\
		--disable-static					\
		$(use_enable gtk poppler-glib)				\
		$(use_enable qt3 poppler-qt)				\
		$(use_enable qt4 poppler-qt4)				\
		$(use cairo && echo "--enable-poppler-glib")		\
		$(use_enable cairo cairo-output)			\
		|| die "configuration failed"
}

src_compile() {
	cd poppler
	if use cairo; then
		emake libpoppler-cairo.la || die "cairo failed"
	fi
	if use qt4; then
		emake libpoppler-arthur.la || die "arthur failed"
	fi
	cd ..
	emake || die "compilation failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	rm -f $(find "${ED}" -name '*.la')
}

pkg_postinst() {
	ewarn "You need to rebuild everything depending on poppler, use revdep-rebuild"
}
