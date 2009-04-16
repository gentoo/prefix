# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/djvu/djvu-3.5.21_p20090103.ebuild,v 1.8 2009/04/15 16:53:46 ranger Exp $

EAPI=1
inherit fdo-mime nsplugins flag-o-matic eutils multilib toolchain-funcs confutils

MY_P="${PN}libre-${PV#*_p}"

DESCRIPTION="DjVu viewers, encoders and utilities."
HOMEPAGE="http://djvu.sourceforge.net"
SRC_URI="mirror://sourceforge/djvu/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE="xml qt3 jpeg tiff debug nls nsplugin kde doc"

RDEPEND="jpeg? ( >=media-libs/jpeg-6b-r2 )
	tiff? ( media-libs/tiff )
	qt3? ( x11-libs/qt:3 )"
DEPEND="${RDEPEND}
	qt3? ( nsplugin? ( x11-libs/libXt ) )"

S=${WORKDIR}/${MY_P}

LANGS="cs de en fr ja zh"
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

	epatch "${FILESDIR}"/${PN}-3.5.21-interix-atomic.patch
}

src_compile() {
	[[ ${CHOST} == *-interix* ]] && append-flags -D_REENTRANT

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

	# We install all desktop files by hand.
	econf --disable-desktopfiles \
		$(use_with qt3 qt) \
		$(use_enable xml xmltools) \
		$(use_with jpeg) \
		$(use_with tiff) \
		"${I18N}" \
		$(use_enable debug) \
		${QTCONF}

	if ! use nsplugin; then
		sed -e 's:nsdejavu::' -i "${S}"/gui/Makefile || die
	fi

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" plugindir=/usr/$(get_libdir)/${PLUGINS_DIR} install

	dodoc README TODO NEWS

	use doc && cp -r doc/ "${ED}"/usr/share/doc/${PF}

	# Install desktop files.
	cd desktopfiles
	insinto /usr/share/icons/hicolor/22x22/mimetypes && newins hi22-djvu.png image-vnd.djvu.png || die
	insinto	/usr/share/icons/hicolor/32x32/mimetypes && newins hi32-djvu.png image-vnd.djvu.png || die
	insinto	/usr/share/icons/hicolor/48x48/mimetypes && newins hi48-djvu.png image-vnd.djvu.png || die
	insinto	/usr/share/mime/packages && doins djvulibre-mime.xml || die
	if use kde ; then
		insinto /usr/share/mimelnk/image && doins vnd.djvu.desktop || die
		cp "${ED}"/usr/share/mimelnk/image/{vnd.djvu.desktop,x-djvu.desktop}
		sed -i -e 's:image/vnd.djvu:image/x-djvu:' "${ED}"/usr/share/mimelnk/image/x-djvu.desktop
	fi

	if use qt3 ; then
		insinto /usr/share/icons/hicolor/32x32/apps && newins hi32-djview3.png djvulibre-djview3.png || die
		insinto /usr/share/applications/ && doins djvulibre-djview3.desktop || die
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
