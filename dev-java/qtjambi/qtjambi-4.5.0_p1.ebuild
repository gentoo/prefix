# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/qtjambi/qtjambi-4.5.0_p1.ebuild,v 1.1 2009/07/22 07:29:15 ali_bush Exp $

EAPI="2"

JAVA_PKG_IUSE="doc source"
WANT_ANT_TASKS="ant-trax"

inherit eutils qt4 java-pkg-2 java-ant-2 toolchain-funcs multilib

QTVER="${PV%%_p*}"
MY_PV="${PV/p/0}"
MY_P="${PN}-src-lgpl-${MY_PV}"

DESCRIPTION="QtJambi is a set of Java bindings and utilities for the Qt C++ toolkit."
HOMEPAGE="http://www.qtsoftware.com/"
SRC_URI="http://get.qtsoftware.com/${PN}/source/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="4"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="debug examples opengl phonon webkit xmlpatterns"

COMMON_DEPS=">=x11-libs/qt-gui-${QTVER}:${SLOT}
	>=x11-libs/qt-sql-${QTVER}:${SLOT}
	>=x11-libs/qt-svg-${QTVER}:${SLOT}
	opengl? ( >=x11-libs/qt-opengl-${QTVER}:${SLOT} )
	phonon? ( >=x11-libs/qt-phonon-${QTVER}:${SLOT} )
	webkit? ( >=x11-libs/qt-webkit-${QTVER}:${SLOT} )
	xmlpatterns? ( >=x11-libs/qt-xmlpatterns-${QTVER}:${SLOT} )"

DEPEND="${COMMON_DEPS}
	>=virtual/jdk-1.6"

RDEPEND="${COMMON_DEPS}
	>=virtual/jre-1.6"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	epatch "${FILESDIR}/generator-${PV}.patch"
	epatch "${FILESDIR}/configuration-${PV}.patch"

	if [[ $(gcc-version) == "4.4" ]] ; then
		epatch "${FILESDIR}/gcc4.4-${PV}.patch"
	fi

	# Respect MAKEOPTS
	sed -i -e "/String arguments =/s|=.*|=\" ${MAKEOPTS}\";|" \
		com/trolltech/tools/ant/MakeTask.java || die

	java-ant_rewrite-classpath

	epatch "${FILESDIR}"/${PN}-darwin-fix-framework.patch
	# remove hardcoded path to tiger sdk
	sed -e '/^    QMAKE_MAC_SDK/d' \
		-i designer-integration/pri/jambi.pri qtjambi/qtjambi_base.pri \
		   generator_example/generator_example.pro
	# fix install_names
	sed -i designer-integration/pri/jambi.pri \
		-e "/^macx:/a\    INSTALL_PREFIX = ${EPREFIX}/usr/$(get_libdir)/qt4/plugins/designer" \
		|| die "sed failed"
	# fix install_names
	sed -i qtjambi/qtjambi_base.pri \
		-e "/^macx:/a\    INSTALL_PREFIX = ${EPREFIX}/usr/$(get_libdir)/qt4" \
		|| die "sed failed"
}

qtjambi_use() {
	echo "-Dgentoo.${2:-$1}=$(use $1 && echo true || echo false)"
}

qt_config_use() {
	echo "QT_CONFIG$(use $1 && echo '+' || echo '-')=$1"
}

src_compile() {
	local myconf="-Dqtjambi.config=$(use debug && echo debug || echo release)
			-Dlibrary.designer=true
			$(qtjambi_use opengl)
			$(qtjambi_use phonon)
			$(qtjambi_use webkit)
			$(qtjambi_use xmlpatterns)"
	export QTDIR="${EPREFIX}/usr/$(get_libdir)/qt4"

	einfo "Initializing Qt Jambi build environment"
	eant -Dgentoo.classpath="$(java-pkg_getjar --build-only ant-core ant.jar)" \
		${myconf} init

	einfo "Merging XML files used by the Qt Jambi generator"
	eant ${myconf} generator.xmlmerge

	# Use eqmake4 instead of generator.qmake ant target
	eqmake4 generator/generator.pro -o generator/Makefile

	einfo "Building and running the generator"
	eant ${myconf} generator.run   # implies generator.compile

	# Use eqmake4 instead of library.native.qmake ant target
	eqmake4 java.pro -recursive \
		$(qt_config_use opengl) \
		$(qt_config_use phonon) \
		$(qt_config_use webkit) \
		$(qt_config_use xmlpatterns)

	einfo "Building the native library"
	eant ${myconf} library.native.compile

	einfo "Building the Java library"
	eant ${myconf} library.java

	einfo "Building the Designer library"
	eant ${myconf} library.designer

	if use examples; then
		einfo "Building examples"
		eant ${myconf} examples
	fi

	# Build API documentation
	if use doc; then
		einfo "Generating Javadoc"
		javadoc -J-Xmx256m -d javadoc -subpackages com || die
	fi

	# Generate start script for jambi-designer
	cat > bin/jambi-designer <<-EOF
		#!${EPREFIX}/bin/sh
		export LD_LIBRARY_PATH="${EPREFIX}/usr/$(get_libdir)/qt4:${EPREFIX}/usr/$(get_libdir)/${PN}-${SLOT}:\${LD_LIBRARY_PATH}"
		export
		CLASSPATH="${EPREFIX}/usr/share/${PN}-${SLOT}/lib/${PN}.jar:${EPREFIX}/usr/share/${PN}-${SLOT}/lib/${PN}-designer.jar:\${CLASSPATH}"
		export QT_PLUGIN_PATH="${EPREFIX}/usr/$(get_libdir)/qt4/plugins"
		exec "${EPREFIX}"/usr/bin/designer "\$@"
	EOF
}

src_install() {
	dobin "${S}"/bin/* || die
	newbin "${S}"/generator/generator jambi-generator || die

	einfo "Installing jars"
	java-pkg_newjar qtjambi-${MY_PV}.jar
	java-pkg_newjar qtjambi-designer-${MY_PV}.jar ${PN}-designer.jar
	java-pkg_dojar ant-qtjambi.jar

	einfo "Installing native libraries"
	# `java-pkg_doso "${S}"/lib/*` does not work (bug #251500)
	java-pkg_doso "${S}"/lib/*$(get_libname 1.0.0) "${S}"/lib/*$(get_libname 1.0) "${S}"/lib/*$(get_libname 1) "${S}"/lib/*$(get_libname)

	einfo "Installing designer plugins"
	exeinto /usr/$(get_libdir)/qt4/plugins/${PN}
	doexe plugins/designer/*$(get_libname) || die
	# Designer needs these libraries in both directories
	dosym /usr/$(get_libdir)/qt4/plugins/${PN}/libJambiCustomWidget$(get_libname) \
		/usr/$(get_libdir)/qt4/plugins/designer/libJambiCustomWidget$(get_libname)
	dosym /usr/$(get_libdir)/qt4/plugins/${PN}/libJambiLanguage$(get_libname) \
		/usr/$(get_libdir)/qt4/plugins/designer/libJambiLanguage$(get_libname)

	if use doc; then
		einfo "Installing documentation"
		dohtml "${S}"/readme.html
		java-pkg_dojavadoc "${S}"/javadoc
	fi

	if use examples; then
		einfo "Installing examples"

		# Get rid of class files before installing
		find "${S}"/com/trolltech/examples -name '*.class' -delete || die

		java-pkg_newjar qtjambi-examples-${MY_PV}.jar ${PN}-examples.jar
		java-pkg_doexamples "${S}"/com/trolltech/examples
		java-pkg_dolauncher jambi-examples --main com.trolltech.launcher.Launcher \
			--java_args "-Djava.library.path=${EPREFIX}/usr/$(get_libdir)/qt4:${EPREFIX}/usr/$(get_libdir)/${PN}-${SLOT}"
	fi

	use source && java-pkg_dosrc "${S}"/com
}
