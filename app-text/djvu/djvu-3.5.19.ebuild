# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/djvu/djvu-3.5.19.ebuild,v 1.2 2007/05/22 11:21:22 pva Exp $

EAPI="prefix"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"
inherit fdo-mime nsplugins flag-o-matic eutils multilib toolchain-funcs autotools

MY_P="${PN}libre-${PV}"

DESCRIPTION="DjVu viewers, encoders and utilities."
HOMEPAGE="http://djvu.sourceforge.net"
SRC_URI="mirror://sourceforge/djvu/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-solaris"
IUSE="xml qt3 jpeg tiff debug threads nls nsplugin kde doc"

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
	cd "${S}"

	# Do not strip binaries as portage does this for us. bug #135208
	sed -i 's:${INSTALL_PROGRAM} -s:${INSTALL_PROGRAM}:' \
		gui/djview/Makefile.in tools/Makefile.in xmltools/Makefile.in

	# Fix compilaton with --as-needed. bug #132473
	epatch "${FILESDIR}"/djvulibre-3.5.17-pthread-flag.patch

	AT_M4DIR="config" eautoreconf
}

src_compile() {
	# assembler problems and hence non-building with pentium4
	# <obz@gentoo.org>
	replace-flags -march=pentium4 -march=pentium3
	echo LINGUAS=$LINGUAS

	# When enabling qt it must be compiled with threads. See bug #89544.
	if use qt3 ; then
		QTCONF=" --with-qt --enable-threads "
	elif use threads ; then
		QTCONF=" --without-qt --disable-djview --enable-threads "
	else
		QTCONF=" --without-qt --disable-djview --disable-threads "
	fi

	# We install all desktop files by hand.
	econf --disable-desktopfiles \
		$(use_enable xml xmltools) \
		$(use_with jpeg) \
		$(use_with tiff) \
		$(use_enable nls i18n) \
		$(use_enable debug) \
		${QTCONF} \
		|| die "econf failed"

	if ! use nsplugin; then
		sed -e 's:nsdejavu::' -i "${S}"/gui/Makefile || die
	fi

	emake -j1 || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" plugindir=/usr/$(get_libdir)/${PLUGINS_DIR} install

	dodoc README TODO NEWS

	use doc && cp -r doc/ "${ED}"/usr/share/doc/${PF}

	# Install desktop files.
	cd desktopfiles
	insinto /usr/share/icons/hicolor/22x22/mimetypes && newins hi22-djvu.png image-vnd.djvu.png
	insinto	/usr/share/icons/hicolor/32x32/mimetypes && newins hi32-djvu.png image-vnd.djvu.png
	insinto	/usr/share/icons/hicolor/48x48/mimetypes && newins hi48-djvu.png image-vnd.djvu.png
	insinto	/usr/share/mime/packages && doins djvulibre-mime.xml
	if use kde ; then
		insinto /usr/share/mimelnk/image && doins vnd.djvu.desktop x-djvu.desktop
		cp "${ED}"/usr/share/mimelnk/image/{vnd.djvu.desktop,x-djvu.desktop}
		sed -i -e 's:image/vnd.djvu:image/x-djvu:' "${ED}"/usr/share/mimelnk/image/x-djvu.desktop
	fi

	insinto /usr/share/icons/hicolor/32x32/apps && newins hi32-djview3.png djvulibre-djview3.png
	insinto /usr/share/applications/ && doins djvulibre-djview3.desktop
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}
