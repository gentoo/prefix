# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/x11-libs/qt/qt-4.2.2.ebuild,v 1.12 2007/02/01 18:32:13 corsair Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs multilib

SRCTYPE="opensource-src"
DESCRIPTION="The Qt toolkit is a comprehensive C++ application development framework."
HOMEPAGE="http://www.trolltech.com/"

SRC_URI="!aqua? ( ftp://ftp.trolltech.com/pub/qt/source/qt-x11-${SRCTYPE}-${PV}.tar.gz )
	aqua? ( ftp://ftp.trolltech.com/pub/qt/source/qt-mac-${SRCTYPE}-${PV}.tar.gz )"
use aqua || S=${WORKDIR}/qt-x11-${SRCTYPE}-${PV}
use aqua && S=${WORKDIR}/qt-mac-${SRCTYPE}-${PV}

LICENSE="|| ( QPL-1.0 GPL-2 )"
SLOT="4"
KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"

IUSE_INPUT_DEVICES="input_devices_wacom"

IUSE="aqua accessibility cups dbus debug doc examples firebird gif glib jpeg mng mysql nas nis odbc opengl pch png postgres qt3support sqlite sqlite3 xinerama zlib ${IUSE_INPUT_DEVICES}"

DEPEND="!aqua? ( x11-libs/libXrandr
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libXfont
	x11-libs/libSM
	x11-proto/xextproto
	x11-proto/inputproto 
	virtual/xft )
	dev-util/pkgconfig
	xinerama? ( x11-proto/xineramaproto x11-libs/libXinerama )
	>=media-libs/freetype-2
	png? ( media-libs/libpng )
	jpeg? ( media-libs/jpeg )
	mng? ( >=media-libs/libmng-1.0.9 )
	nas? ( >=media-libs/nas-1.5 )
	odbc? ( dev-db/unixODBC )
	mysql? ( virtual/mysql )
	firebird? ( dev-db/firebird )
	sqlite3? ( =dev-db/sqlite-3* )
	sqlite? ( =dev-db/sqlite-2* )
	postgres? ( dev-db/libpq )
	cups? ( net-print/cups )
	zlib? ( sys-libs/zlib )
	glib? ( dev-libs/glib )
	dbus? ( >=sys-apps/dbus-0.93 )
	input_devices_wacom? ( x11-drivers/linuxwacom )"

pkg_setup() {
	QTBASEDIR=${EPREFIX}/usr/$(get_libdir)/qt4
	QTPREFIXDIR=${EPREFIX}/usr
	QTBINDIR=${EPREFIX}/usr/bin
	QTLIBDIR=${EPREFIX}/usr/$(get_libdir)/qt4
	QTPCDIR=${EPREFIX}/usr/$(get_libdir)/pkgconfig
	QTDATADIR=${EPREFIX}/usr/share/qt4
	QTDOCDIR=${EPREFIX}/usr/share/doc/${PF}
	QTHEADERDIR=${EPREFIX}/usr/include/qt4
	QTPLUGINDIR=${QTLIBDIR}/plugins
	QTSYSCONFDIR=${EPREFIX}/etc/qt4
	QTTRANSDIR=${QTDATADIR}/translations
	QTEXAMPLESDIR=${QTDATADIR}/examples
	QTDEMOSDIR=${QTDATADIR}/demos

	PLATFORM=$(qt_mkspecs_dir)

}

qt_use() {
	useq ${1} && echo "-${1}" || echo "-no-${1}"
	return 0
}

qt_mkspecs_dir() {
	 # Allows us to define which mkspecs dir we want to use.
	local spec

	case ${CHOST} in
		*-freebsd*|*-dragonfly*)
			spec="freebsd" ;;
		*-openbsd*)
			spec="openbsd" ;;
		*-netbsd*)
			spec="netbsd" ;;
		*-darwin*)
			spec="macx" ;;
		*-linux-*|*-linux)
			spec="linux" ;;
		*)
			die "Unknown CHOST, no platform choosed."
	esac

	CXX=$(tc-getCXX)
	if [[ ${CXX/g++/} != ${CXX} ]]; then
		spec="${spec}-g++"
	elif [[ ${CXX/icpc/} != ${CXX} ]]; then
		spec="${spec}-icc"
	else
		die "Unknown compiler ${CXX}."
	fi

	echo "${spec}"
}

src_unpack() {

	unpack ${A}
	cd ${S}
#	epatch ${FILESDIR}/qt4-parisc-linux.diff
#	epatch ${FILESDIR}/qt-4.1.4-sparc.patch
	epatch ${FILESDIR}/qt4-sqlite-configure.patch

	cd ${S}/mkspecs/$(qt_mkspecs_dir)
	# set c/xxflags and ldflags

	# Don't let the user go too overboard with flags.  If you really want to, uncomment
	# out the line below and give 'er a whirl.
	strip-flags
	replace-flags -O3 -O2
	
	sed -i -e "s:QMAKE_CFLAGS[^_]*=.*:QMAKE_CFLAGS=${CFLAGS}:" \
		-e "s:QMAKE_CXXFLAGS[^_]*=.*:QMAKE_CXXFLAGS=${CXXFLAGS}:" \
		-e "s:QMAKE_LFLAGS[^_]*=\(.*\):QMAKE_LFLAGS=\1 ${LDFLAGS}:" \
		qmake.conf

	# Do not link with -rpath. See bug #75181.
	sed -i -e "s:QMAKE_RPATH.*=.*:QMAKE_RPATH=:" qmake.conf

	# Replace X11R6/ directories, so /usr/X11R6/lib -> /usr/lib
	sed -i -e "s:X11R6/::" qmake.conf

	# The trolls moved the definitions of the above stuff for g++, so we need to edit those files
	# separately as well.
	cd ${S}/mkspecs/common

	sed -i -e "s:QMAKE_CFLAGS[^_]*=.*:QMAKE_CFLAGS+=${CFLAGS}:" \
		-e "s:QMAKE_CXXFLAGS[^_]*=.*:QMAKE_CXXFLAGS+=${CXXFLAGS}:" \
		-e "s:QMAKE_LFLAGS[^_]*=.*:QMAKE_LFLAGS+=${LDFLAGS}:" \
		g++.conf

	# Do not link with -rpath. See bug #75181.
	sed -i -e "s:QMAKE_RPATH.*=.*:QMAKE_RPATH=:" g++.conf

	# Replace X11R6/ directories, so /usr/X11R6/lib -> /usr/lib
	sed -i -e "s:X11R6/::" *.conf

	cd ${S}

}

src_compile() {
	export PATH="${S}/bin:${PATH}"
	export LD_LIBRARY_PATH="${S}/lib:${LD_LIBRARY_PATH}"

	[ $(get_libdir) != "lib" ] && myconf="${myconf} -L/usr/$(get_libdir)"

	# Disable visibility explicitly if gcc version isn't 4
	if [[ "$(gcc-major-version)" != "4" ]]; then
		myconf="${myconf} -no-reduce-exports"
	fi

	myconf="${myconf} $(qt_use accessibility) $(qt_use cups) $(qt_use xinerama)"
	myconf="${myconf} $(qt_use opengl) $(qt_use nis)"

	use nas		&& myconf="${myconf} -system-nas-sound"
	use gif		&& myconf="${myconf} -qt-gif" || myconf="${myconf} -no-gif"
	use png		&& myconf="${myconf} -system-libpng" || myconf="${myconf} -qt-libpng"
	use jpeg	&& myconf="${myconf} -system-libjpeg" || myconf="${myconf} -qt-libjpeg"
	use debug	&& myconf="${myconf} -debug -separate-debug-info" || myconf="${myconf} -release -no-separate-debug-info"
	use zlib	&& myconf="${myconf} -system-zlib" || myconf="${myconf} -qt-zlib"

	use mysql	&& myconf="${myconf} -plugin-sql-mysql -I/usr/include/mysql -L/usr/$(get_libdir)/mysql" || myconf="${myconf} -no-sql-mysql"
	use postgres	&& myconf="${myconf} -plugin-sql-psql -I/usr/include/postgresql/pgsql" || myconf="${myconf} -no-sql-psql"
	use firebird	&& myconf="${myconf} -plugin-sql-ibase" || myconf="${myconf} -no-sql-ibase"
	use sqlite3	&& myconf="${myconf} -plugin-sql-sqlite -system-sqlite" || myconf="${myconf} -no-sql-sqlite"
	use sqlite	&& myconf="${myconf} -plugin-sql-sqlite2" || myconf="${myconf} -no-sql-sqlite2"
	use odbc	&& myconf="${myconf} -plugin-sql-odbc" || myconf="${myconf} -no-sql-odbc"

	use dbus	&& myconf="${myconf} -qdbus" || myconf="${myconf} -no-qdbus"
	use glib	&& myconf="${myconf} -glib" || myconf="${myconf} -no-glib"
	use qt3support		&& myconf="${myconf} -qt3support" || myconf="${myconf} -no-qt3support"

	use pch		&& myconf="${myconf} -pch"

	use input_devices_wacom	&& myconf="${myconf} -tablet" || myconf="${myconf} -no-tablet"

	myconf="${myconf} -xrender -xrandr -xkb -xshape -sm"

	if ! use examples; then
		myconf="${myconf} -nomake examples"
	fi


	./configure -stl -verbose -largefile -confirm-license \
		-platform ${PLATFORM} -xplatform ${PLATFORM} \
		-prefix ${QTPREFIXDIR} -bindir ${QTBINDIR} -libdir ${QTLIBDIR} -datadir ${QTDATADIR} \
		-docdir ${QTDOCDIR} -headerdir ${QTHEADERDIR} -plugindir ${QTPLUGINDIR} \
		-sysconfdir ${QTSYSCONFDIR} -translationdir ${QTTRANSDIR} \
		-examplesdir ${QTEXAMPLESDIR} -demosdir ${QTDEMOSDIR} ${myconf} || die

	#emake all
	#sed -i -e "s:^LINK[^=]*=.*:LINK = c++ -dynamiclib:" src/corelib/Makefile.Release
	emake all || die

}

src_install() {
	export PATH="${S}/bin:${PATH}"
	export LD_LIBRARY_PATH="${S}/lib:${LD_LIBRARY_PATH}"

	make INSTALL_ROOT=${D} install_subtargets || die
	make INSTALL_ROOT=${D} install_qmake || die
	make INSTALL_ROOT=${D} install_mkspecs || die

	if use doc; then
		make INSTALL_ROOT=${D} install_htmldocs || die
	fi

	# Install the translations.  This may get use flagged later somehow
	make INSTALL_ROOT=${D} install_translations || die

	keepdir "${QTSYSCONFDIR/${EPREFIX}}"

	insinto ${QTLIBDIR/${EPREFIX}}
	doins lib/*.{la,pc}

	(
		find ${D}/${QTLIBDIR} -name "*.la"
		find ${D}/${QTLIBDIR} -name "*.prl"
		find ${D}/${QTLIBDIR} -name "*.pc"
	) | xargs \
	sed -i -e "s:${S}/lib:${QTLIBDIR}:g"
	sed -i -e "s:${S}/bin:${QTBINDIR}:g" ${D}/${QTLIBDIR}/*.pc

	# Move .pc files into the pkgconfig directory
	dodir ${QTPCDIR/${EPREFIX}}
	mv ${D}/${QTLIBDIR}/*.pc ${D}/${QTPCDIR}

	# List all the multilib libdirs
	local libdirs
	for libdir in $(get_all_libdirs); do
		libdirs="${libdirs}:${EPREFIX}/usr/${libdir}/qt4"
	done

	cat > "${T}/44qt4" << EOF
LDPATH=${libdirs:1}
QMAKESPEC=$(qt_mkspecs_dir)
EOF
	doenvd "${T}/44qt4"
}
