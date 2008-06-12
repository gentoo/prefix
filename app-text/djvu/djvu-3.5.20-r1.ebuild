# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/djvu/djvu-3.5.20-r1.ebuild,v 1.8 2008/03/22 16:34:04 coldwind Exp $

EAPI="prefix"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"
inherit fdo-mime nsplugins flag-o-matic eutils multilib toolchain-funcs autotools confutils

MY_P="${PN}libre-${PV}"

DESCRIPTION="DjVu viewers, encoders and utilities."
HOMEPAGE="http://djvu.sourceforge.net"
SRC_URI="mirror://sourceforge/djvu/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE="xml qt3 jpeg tiff debug threads nls nsplugin kde doc"

DEPEND="jpeg? ( >=media-libs/jpeg-6b-r2 )
	tiff? ( media-libs/tiff )
	qt3? ( =x11-libs/qt-3* )"

S=${WORKDIR}/${MY_P}

LANGS="cs de fr ja"
for X in ${LANGS}; do
	IUSE="${IUSE} linguas_${X}"
done

pkg_setup() {
	if ! use qt3; then
		ewarn
		ewarn "The standalone djvu viewer, djview, will not be compiled."
		ewarn "Add \"qt3\" to your USE flags if you want it."
		ewarn
	fi

	confutils_use_depend_all nsplugin qt3
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Do not strip binaries as portage does this for us. bug #135208
	find -name Makefile.in -exec sed -i 's:${INSTALL_PROGRAM} -s:${INSTALL_PROGRAM}:' \{\} \;

	cp "${EPREFIX}"/usr/share/aclocal/libtool.m4 config/libtool.m4
	eautoreconf # need new libtool for interix
}

src_compile() {
	# assembler problems and hence non-building with pentium4
	# <obz@gentoo.org>
	replace-flags -march=pentium4 -march=pentium3

	[[ ${CHOST} == *-interix* ]] && append-flags -D_ALL_SOURCE -D_REENTRANT

	local I18N
	if use nls; then
		for X in ${LANGS}; do
			if use linguas_${X}; then
				I18N="${I18N} ${X}"
			fi
		done
		I18N="${I18N# }"
		if test -n "$I18N"; then
			I18N="--enable-i18n=${I18N}"
		else
			I18N="--enable-i18n"
		fi
	else
		I18N="--disable-i18n"
	fi

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
		"${I18N}" \
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

	if use qt3 ; then
		insinto /usr/share/icons/hicolor/32x32/apps && newins hi32-djview3.png djvulibre-djview3.png
		insinto /usr/share/applications/ && doins djvulibre-djview3.desktop
	fi
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}
