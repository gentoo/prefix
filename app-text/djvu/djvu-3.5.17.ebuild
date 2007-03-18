# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/djvu/djvu-3.5.17.ebuild,v 1.17 2007/01/04 14:24:46 flameeyes Exp $

EAPI="prefix"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

inherit nsplugins flag-o-matic fdo-mime eutils multilib toolchain-funcs autotools

MY_P="${PN}libre-${PV}"

DESCRIPTION="DjVu viewers, encoders and utilities."
HOMEPAGE="http://djvu.sourceforge.net"
SRC_URI="mirror://sourceforge/djvu/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE="xml qt3 jpeg tiff debug threads nls nsplugin kde"

DEPEND="jpeg? ( >=media-libs/jpeg-6b-r2 )
	tiff? ( media-libs/tiff )
	qt3? ( <x11-libs/qt-4 )"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	if ! use qt3; then
		ewarn
		ewarn "The standalone djvu viewer, djview, will not be compiled."
		ewarn "Add \"qt3\" to your USE flags if you want it."
		ewarn
	fi
}

src_unpack() {
	unpack ${A}
	cd ${S}

	epatch "${FILESDIR}/${P}-dont-prestrip-bins.patch"
	epatch "${FILESDIR}/djvulibre-3.5.17-pthread-flag.patch"

	# Replace autochecking acdesktop.m4 with a gentoo-specific one
	cp "${FILESDIR}/gentoo-acdesktop.m4" "${S}/gui/desktop/acdesktop.m4"

	AT_M4DIR="config gui/desktop" eautoreconf
}

src_compile() {
	# assembler problems and hence non-building with pentium4
	# <obz@gentoo.org>
	replace-flags -march=pentium4 -march=pentium3

	if use kde ; then
		export kde_mimelnk=/usr/share/mimelnk
	fi

	# When enabling qt it must be compiled with threads. See bug #89544.
	if use qt3 ; then
		QTCONF=" --with-qt --enable-threads "
	elif use threads ; then
		QTCONF=" --enable-threads "
	else
		QTCONF=" --disable-threads "
	fi

	econf --enable-desktopfiles \
		$(use_enable xml xmltools) \
		$(use_with jpeg) \
		$(use_with tiff) \
		$(use_enable nls i18n) \
		$(use_enable debug) \
		${QTCONF} \
		|| die "econf failed"

	if ! use nsplugin; then
		sed -e 's:nsdejavu::' -i ${S}/gui/Makefile || die
	fi

	emake -j1 || die "emake failed"
}

src_install() {
	make DESTDIR=${D} plugindir=/usr/$(get_libdir)/${PLUGINS_DIR} install
}
