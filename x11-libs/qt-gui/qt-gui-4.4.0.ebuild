# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-gui/qt-gui-4.4.0.ebuild,v 1.2 2008/05/25 08:26:36 corsair Exp $

EAPI="prefix 1"
inherit eutils qt4-build

DESCRIPTION="The GUI module(s) for the Qt toolkit."
HOMEPAGE="http://www.trolltech.com/"

LICENSE="|| ( QPL-1.0 GPL-3 GPL-2 )"
SLOT="4"
KEYWORDS="~amd64-linux ~x86-linux"

IUSE_INPUT_DEVICES="input_devices_wacom"
IUSE="+accessibility cups dbus debug glib mng nas nis tiff +qt3support xinerama ${IUSE_INPUT_DEVICES}"

RDEPEND="
	media-libs/fontconfig
	>=media-libs/freetype-2
	media-libs/jpeg
	media-libs/libpng
	sys-libs/zlib
	x11-libs/libXrandr
	x11-libs/libXcursor
	x11-libs/libXfont
	x11-libs/libSM
	~x11-libs/qt-core-${PV}
	~x11-libs/qt-script-${PV}
	cups? ( net-print/cups )
	dbus? ( ~x11-libs/qt-dbus-${PV} )
	input_devices_wacom? ( x11-libs/libXi x11-drivers/linuxwacom )
	mng? ( >=media-libs/libmng-1.0.9 )
	nas? ( >=media-libs/nas-1.5 )
	tiff? ( media-libs/tiff )
	xinerama? ( x11-libs/libXinerama )"
DEPEND="${RDEPEND}
	xinerama? ( x11-proto/xineramaproto )
	x11-proto/xextproto
	x11-proto/inputproto"

QT4_TARGET_DIRECTORIES="
src/gui
tools/designer
tools/linguist
src/plugins/imageformats/gif
src/plugins/imageformats/ico
src/plugins/imageformats/jpeg"
QT4_EXTRACT_DIRECTORIES="
src/tools/rcc/
tools/shared/"

pkg_setup() {
	use glib && QT4_BUILT_WITH_USE_CHECK="${QT4_BUILT_WITH_USE_CHECK}
		~x11-libs/qt-core-${PV} glib"
	use qt3support && QT4_BUILT_WITH_USE_CHECK="${QT4_BUILT_WITH_USE_CHECK}
		~x11-libs/qt-core-${PV} qt3support"

	qt4-build_pkg_setup
}

src_unpack() {
	use dbus && QT4_TARGET_DIRECTORIES="${QT4_TARGET_DIRECTORIES} tools/qdbus/qdbusviewer"
	use mng && QT4_TARGET_DIRECTORIES="${QT4_TARGET_DIRECTORIES} src/plugins/imageformats/mng"
	use tiff && QT4_TARGET_DIRECTORIES="${QT4_TARGET_DIRECTORIES} src/plugins/imageformats/tiff"
	QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
	${QT4_EXTRACT_DIRECTORIES}"

	qt4-build_src_unpack

	# Don't build plugins this go around, because they depend on qt3support lib
	sed -i -e "s:CONFIG(shared:# &:g" "${S}"/tools/designer/src/src.pro

	cd "${S}"
	epatch "${FILESDIR}/${P}-scrollbars.patch"
}

src_compile() {
	export PATH="${S}/bin:${PATH}"
	export LD_LIBRARY_PATH="${S}/lib:${LD_LIBRARY_PATH}"

	local myconf
	myconf="$(qt_use accessibility)
		$(qt_use cups)
		$(qt_use glib)
		$(qt_use input_devices_wacom tablet)
		$(qt_use mng libmng system)
		$(qt_use nis)
		$(qt_use tiff libtiff system)
		$(qt_use qdbus)
		$(qt_use qt3support)
		$(qt_use xinerama)"

	use nas	&& myconf="${myconf} -system-nas-sound"

	myconf="${myconf} -qt-gif -system-libpng -system-libjpeg
		-no-sql-mysql -no-sql-psql -no-sql-ibase -no-sql-sqlite -no-sql-sqlite2 -no-sql-odbc
		-xrender -xrandr -xkb -xshape -sm  -no-svg"

	# Explictly don't compile these packages.
	# Emerge "qt-webkit", "qt-phonon", etc for their functionality.
	myconf="${myconf} -no-webkit -no-phonon -no-dbus -no-opengl"

	qt4-build_src_compile
}

src_install() {
	QCONFIG_ADD="x11sm xshape xcursor xfixes xrandr xrender xkb fontconfig
		$(use input_devices_wacom && echo tablet) $(usev accessibility)
		$(usev xinerama) $(usev cups) $(usev nas) gif png system-png system-jpeg
		$(use mng && echo system-mng) $(use tiff && echo system-tiff)"
	QCONFIG_REMOVE="no-gif no-png"
	QCONFIG_DEFINE="$(use accessibility && echo QT_ACCESSIBILITY)
	$(use cups && echo QT_CUPS) QT_FONTCONFIG QT_IMAGEFORMAT_JPEG
	$(use mng && echo QT_IMAGEFORMAT_MNG) $(use nas && echo QT_NAS)
	$(use nis && echo QT_NIS) QT_IMAGEFORMAT_PNG QT_SESSIONMANAGER QT_SHAPE
	$(use tiff && echo QT_IMAGEFORMAT_TIFF) QT_XCURSOR
	$(use xinerama && echo QT_XINERAMA) QT_XFIXES QT_XKB QT_XRANDR QT_XRENDER"
	qt4-build_src_install

	domenu "${FILESDIR}"/{Designer,Linguist}.desktop
}

pkg_postinst()
{
	qconfig_add_option x11sm
	qconfig_add_option xshape
	qconfig_add_option xcursor
	qconfig_add_option xfixes
	qconfig_add_option xrandr
	qconfig_add_option xrender
	qconfig_add_option xkb
	qconfig_add_option fontconfig
	use input_devices_wacom && qconfig_add_option tablet
	use accessibility && qconfig_add_option accessibility
	use xinerama && qconfig_add_option xinerama
	use cups && qconfig_add_option cups
	use nas && qconfig_add_option nas

	qconfig_remove_option no-gif
	qconfig_add_option gif

	qconfig_remove_option no-png
	qconfig_add_option png
	qconfig_add_option system-png

	# Need to do the same for tiff and mng
}

pkg_postrm()
{
	qconfig_remove_option x11sm
	qconfig_remove_option xshape
	qconfig_remove_option xcursor
	qconfig_remove_option xfixes
	qconfig_remove_option xrandr
	qconfig_remove_option xrender
	qconfig_remove_option xkb
	qconfig_remove_option fontconfig

	qconfig_remove_option tablet
	qconfig_remove_option accessibility
	qconfig_remove_option xinerama
	qconfig_remove_option cups
	qconfig_remove_option nas

	qconfig_remove_option png
	qconfig_remove_option system-png
	qconfig_add_option no-png

	qconfig_remove_option gif
	qconfig_add_option no-gif

	# Need to do the same for tiff and mng
}
