# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-sql/qt-sql-4.4.0_rc1.ebuild,v 1.5 2007/12/24 14:39:52 caleb Exp $

EAPI="prefix"

inherit qt4-build

SRCTYPE="preview-opensource-src"
DESCRIPTION="The SQL module for the Qt toolkit."
HOMEPAGE="http://www.trolltech.com/"

MY_PV=${PV/_rc/-tp}

SRC_URI="!aqua? ( ftp://ftp.trolltech.com/pub/qt/source/qt-x11-${SRCTYPE}-${MY_PV}.tar.gz )
	aqua? ( ftp://ftp.trolltech.com/pub/qt/source/qt-mac-${SRCTYPE}-${MY_PV}.tar.gz )"
use aqua || S=${WORKDIR}/qt-x11-${SRCTYPE}-${MY_PV}
use aqua && S=${WORKDIR}/qt-mac-${SRCTYPE}-${MY_PV}

LICENSE="|| ( QPL-1.0 GPL-2 )"
SLOT="4"
KEYWORDS="~x86-linux ~ppc-macos ~x86-macos"

IUSE="firebird mysql odbc postgres sqlite"

RDEPEND="~x11-libs/qt-core-${PV}
		mysql? ( virtual/mysql )
		firebird? ( dev-db/firebird )
		sqlite? ( =dev-db/sqlite-3* )
		postgres? ( dev-db/libpq )
		odbc? ( dev-db/unixODBC )"

DEPEND="${RDEPEND}"

QT4_TARGET_DIRECTORIES="src/sql src/plugins/sqldrivers"

src_unpack() {
	qt4-build_src_unpack

	skip_qmake_build_patch
	skip_project_generation_patch
	install_binaries_to_buildtree
}

src_compile() {
	local myconf=$(standard_configure_options)

	use mysql       && myconf="${myconf} -plugin-sql-mysql -I/usr/include/mysql -L/usr/$(get_libdir)/mysql" || myconf="${myconf} -no-sql-mysql"
	use postgres    && myconf="${myconf} -plugin-sql-psql -I/usr/include/postgresql/pgsql" || myconf="${myconf} -no-sql-psql"
	use firebird    && myconf="${myconf} -plugin-sql-ibase -I/opt/firebird/include" || myconf="${myconf} -no-sql-ibase"
	use sqlite      && myconf="${myconf} -plugin-sql-sqlite -system-sqlite" || myconf="${myconf} -no-sql-sqlite"
	use odbc        && myconf="${myconf} -plugin-sql-odbc" || myconf="${myconf} -no-sql-odbc"

	# Don't support sqlite2 anymore
	myconf="${myconf} -no-sql-sqlite2"

	if built_with_use ~x11-libs/qt-core-${PV} qt3support; then
		myconf="${myconf} -qt3support"
	else
		myconf="${myconf} -no-qt3support"
	fi
	myconf="${myconf} -no-xkb -no-tablet -no-fontconfig -no-xrender -no-xrandr -no-xfixes -no-xcursor \
	-no-xinerama -no-xshape -no-sm -no-opengl -no-nas-sound -no-qdbus -iconv -no-cups -no-nis \
	-no-gif -no-libpng -no-libmng -no-libjpeg -no-openssl -system-zlib -no-webkit -no-phonon \
	-no-xmlpatterns -no-freetype -no-libtiff  -no-accessibility -no-fontconfig -no-glib -no-opengl"

	echo ./configure ${myconf}
	./configure ${myconf} || die

	build_target_directories
}
