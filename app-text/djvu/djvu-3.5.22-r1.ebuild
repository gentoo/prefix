# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/djvu/djvu-3.5.22-r1.ebuild,v 1.7 2010/07/23 20:57:40 ssuominen Exp $

EAPI="2"
inherit fdo-mime autotools flag-o-matic

MY_P="${PN}libre-${PV#*_p}"

DESCRIPTION="DjVu viewers, encoders and utilities"
HOMEPAGE="http://djvu.sourceforge.net"
SRC_URI="mirror://sourceforge/djvu/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-solaris"
IUSE="debug doc jpeg nls tiff xml"

RDEPEND="jpeg? ( virtual/jpeg )
	tiff? ( media-libs/tiff )"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

# No gui, only manual pages left and only on ja...
LANGS="ja"
for X in ${LANGS}; do
	IUSE="${IUSE} linguas_${X}"
done

src_prepare() {
	epatch "${FILESDIR}"/${PN}-3.5.21-interix-atomic.patch

	sed 's/AC_CXX_OPTIMIZE/OPTS=;AC_SUBST(OPTS)/' -i configure.ac || die #263688
	rm aclocal.m4 config/{libtool.m4,ltmain.sh,install-sh}
	AT_M4DIR="config" eautoreconf
}

src_configure() {
	local X I18N

	[[ ${CHOST} == *-interix* ]] && append-flags -D_REENTRANT

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

	use debug && append-cppflags "-DRUNTIME_DEBUG_ONLY"

	# We install all desktop files by hand.
	econf --disable-desktopfiles \
		--without-qt \
		$(use_enable xml xmltools) \
		$(use_with jpeg) \
		$(use_with tiff) \
		"${I18N}"
}

src_install() {
	emake DESTDIR="${D}" install || die

	dodoc README TODO NEWS

	use doc && cp -r doc/ "${ED}"/usr/share/doc/${PF}

	# Install desktop files.
	cd desktopfiles
	insinto /usr/share/icons/hicolor/22x22/mimetypes && newins hi22-djvu.png image-vnd.djvu.png || die
	insinto	/usr/share/icons/hicolor/32x32/mimetypes && newins hi32-djvu.png image-vnd.djvu.png || die
	insinto	/usr/share/icons/hicolor/48x48/mimetypes && newins hi48-djvu.png image-vnd.djvu.png || die
	insinto	/usr/share/mime/packages && doins djvulibre-mime.xml || die
}

pkg_postinst() {
	fdo-mime_mime_database_update
	elog "For djviewer or browser plugin, emerge app-text/djview4."
}

pkg_postrm() {
	fdo-mime_mime_database_update
}
