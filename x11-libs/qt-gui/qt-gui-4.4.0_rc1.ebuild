# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-gui/qt-gui-4.4.0_rc1.ebuild,v 1.9 2008/01/23 12:12:35 caleb Exp $

EAPI="prefix"

inherit eutils qt4-build

SRCTYPE="preview-opensource-src"
DESCRIPTION="The GUI module(s) for the Qt toolkit."
HOMEPAGE="http://www.trolltech.com/"

MY_PV=${PV/_rc/-tp}

SRC_URI="!aqua? ( ftp://ftp.trolltech.com/pub/qt/source/qt-x11-${SRCTYPE}-${MY_PV}.tar.gz )
	aqua? ( ftp://ftp.trolltech.com/pub/qt/source/qt-mac-${SRCTYPE}-${MY_PV}.tar.gz )"
use aqua || S=${WORKDIR}/qt-x11-${SRCTYPE}-${MY_PV}
use aqua && S=${WORKDIR}/qt-mac-${SRCTYPE}-${MY_PV}

LICENSE="|| ( QPL-1.0 GPL-2 )"
SLOT="4"
KEYWORDS="~x86-linux ~ppc-macos ~x86-macos"

IUSE_INPUT_DEVICES="input_devices_wacom"

IUSE="accessibility cups dbus debug mng nas nis tiff xinerama ${IUSE_INPUT_DEVICES}"

RDEPEND="~x11-libs/qt-core-${PV}
	~x11-libs/qt-script-${PV}
	dbus? ( ~x11-libs/qt-dbus-${PV} )
	!aqua? ( x11-libs/libXrandr
	x11-libs/libXcursor
	x11-libs/libXfont
	x11-libs/libSM )
	xinerama? ( x11-libs/libXinerama )
	media-libs/fontconfig
	>=media-libs/freetype-2
	media-libs/libpng
	media-libs/jpeg
	sys-libs/zlib
	mng? ( >=media-libs/libmng-1.0.9 )
	tiff? ( media-libs/tiff )
	nas? ( >=media-libs/nas-1.5 )
	cups? ( net-print/cups )
	input_devices_wacom? ( x11-libs/libXi x11-drivers/linuxwacom )"

DEPEND="${RDEPEND}
	xinerama? ( x11-proto/xineramaproto )
	!aqua? ( x11-proto/xextproto
	x11-proto/inputproto )"

QT4_TARGET_DIRECTORIES="src/gui tools/designer tools/linguist src/plugins/imageformats/gif src/plugins/imageformats/ico src/plugins/imageformats/jpeg src/plugins/designer"

src_unpack() {
	qt4-build_src_unpack
	use aqua || epatch "${FILESDIR}"/xinerama.patch

	skip_qmake_build_patch
	skip_project_generation_patch
	install_binaries_to_buildtree

	# Don't build plugins this go around, because they depend on qt3support lib
	sed -i -e "s:CONFIG(shared:#CONFIG(shared:g" "${S}"/tools/designer/src/src.pro
}

src_compile() {
	export PATH="${S}/bin:${PATH}"
	export LD_LIBRARY_PATH="${S}/lib:${LD_LIBRARY_PATH}"

	local myconf=$(standard_configure_options)

	myconf="${myconf} $(qt_use accessibility) $(qt_use cups) $(qt_use xinerama)"
	myconf="${myconf} $(qt_use nis)"

	use nas		&& myconf="${myconf} -system-nas-sound"

	myconf="${myconf} -qt-gif -system-libpng -system-libjpeg"
	myconf="${myconf} $(qt_use tiff libtiff system)"
	myconf="${myconf} $(qt_use mng libmng system)"

	myconf="${myconf} -no-sql-mysql -no-sql-psql -no-sql-ibase -no-sql-sqlite -no-sql-sqlite2 -no-sql-odbc"

	if built_with_use ~x11-libs/qt-core-${PV} glib; then
		myconf="${myconf} -glib"
	else
		myconf="${myconf} -no-glib"
	fi

	if built_with_use ~x11-libs/qt-core-${PV} qt3support; then
		myconf="${myconf} -qt3support"
	else
		myconf="${myconf} -no-qt3support"
	fi

	use input_devices_wacom	&& myconf="${myconf} -tablet" || myconf="${myconf} -no-tablet"

	myconf="${myconf} -xrender -xrandr -xkb -xshape -sm"

	# Explictly don't compile these packages.
	# Emerge "qt-webkit", "qt-phonon", etc for their functionality.
	myconf="${myconf} -no-webkit -no-phonon -no-qdbus -no-opengl"

	use dbus && myconf="${myconf} -qdbus" || myconf="${myconf} -no-qdbus"

	echo ./configure ${myconf}
	./configure ${myconf} || die

	use dbus && QT4_TARGET_DIRECTORIES="${QT4_TARGET_DIRECTORIES} tools/qdbus/qdbusviewer"
	use mng && QT4_TARGET_DIRECTORIES="${QT4_TARGET_DIRECTORIES} src/plugins/imageformats/mng"
	use tiff && QT4_TARGET_DIRECTORIES="${QT4_TARGET_DIRECTORIES} src/plugins/imageformats/tiff"

	build_target_directories
}

src_install() {
	use dbus && QT4_TARGET_DIRECTORIES="${QT4_TARGET_DIRECTORIES} tools/qdbus/qdbusviewer"
	use mng && QT4_TARGET_DIRECTORIES="${QT4_TARGET_DIRECTORIES} src/plugins/imageformats/mng"
	use tiff && QT4_TARGET_DIRECTORIES="${QT4_TARGET_DIRECTORIES} src/plugins/imageformats/tiff"

	qt4-build_src_install

	insinto /usr/share/applications
	doins "${FILESDIR}"/Designer.desktop
	doins "${FILESDIR}"/Linguist.desktop
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
