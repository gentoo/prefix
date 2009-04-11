# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/qtjambi/qtjambi-4.4.3.ebuild,v 1.2 2009/01/19 15:15:48 yngwin Exp $

JAVA_PKG_IUSE="doc source"

inherit eutils java-pkg-2 java-ant-2 multilib

QTVERSION=4.4.2
PATCHRELEASE=01

DESCRIPTION="QtJambi is a set of Java bindings and utilities for the Qt C++ toolkit."
HOMEPAGE="http://www.trolltech.com/"

MY_PV=${PV}_${PATCHRELEASE}

SRC_URI="ftp://ftp.trolltech.no/qtjambi/source/qtjambi-src-gpl-${MY_PV}.tar.gz"
S=${WORKDIR}/qtjambi-src-gpl-${MY_PV}

LICENSE="GPL-2"
SLOT="4"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

IUSE="debug sqlite opengl phonon webkit xmlpatterns examples"

DEPEND=">=x11-libs/qt-gui-${QTVERSION}
	>=virtual/jdk-1.5
	dev-java/ant-trax
	sqlite? ( dev-db/sqlite )
	opengl? ( >=x11-libs/qt-opengl-${QTVERSION} )
	phonon? ( >=x11-libs/qt-phonon-${QTVERSION} )
	webkit? ( >=x11-libs/qt-webkit-${QTVERSION} )
	xmlpatterns? ( >=x11-libs/qt-xmlpatterns-${QTVERSION} )"

RDEPEND=">=x11-libs/qt-gui-${QTVERSION}
	>=virtual/jre-1.5
	sqlite? ( dev-db/sqlite )
	opengl? ( >=x11-libs/qt-opengl-${QTVERSION} )
	phonon? ( >=x11-libs/qt-phonon-${QTVERSION} )
	webkit? ( >=x11-libs/qt-webkit-${QTVERSION} )
	xmlpatterns? ( >=x11-libs/qt-xmlpatterns-${QTVERSION} )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/generator-${PV}.patch"
	epatch "${FILESDIR}/configuration-${PV}.patch"
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

src_compile() {

	cd "${S}"

	# Set build configuration
	local extraArgs="-Dgentoo.qtdir=${EPREFIX}/usr/$(get_libdir)/qt4"

	use debug && extraArgs="${extraArgs} -Dqtjambi.config=debug"

	if use sqlite ; then
	  extraArgs="${extraArgs} -Dgentoo.sqlite=true"
	else
	  extraArgs="${extraArgs} -Dgentoo.sqlite=false"
	fi

	if use opengl ; then
	  extraArgs="${extraArgs} -Dgentoo.opengl=true"
	else
	  extraArgs="${extraArgs} -Dgentoo.opengl=false"
	fi

	if use phonon ; then
	  extraArgs="${extraArgs} -Dgentoo.phonon=true"
	else
	  extraArgs="${extraArgs} -Dgentoo.phonon=false"
	fi

	if use webkit ; then
	  extraArgs="${extraArgs} -Dgentoo.webkit=true"
	else
	  extraArgs="${extraArgs} -Dgentoo.webkit=false"
	fi

	if use xmlpatterns ; then
	  extraArgs="${extraArgs} -Dgentoo.xmlpatterns=true"
	else
	  extraArgs="${extraArgs} -Dgentoo.xmlpatterns=false"
	fi

	# Step 1, Build and run the Qt Jambi generator. The generator relies on QTDIR for include.
	einfo "Building and running the Qt Jambi generator"
	ANT_TASKS="ant-trax" QTDIR="${EPREFIX}/usr/include/qt4" eant -Dgentoo.classpath="$(java-pkg_getjar --build-only ant-core ant.jar)" ${extraArgs} generator

	# Step 2, Build the native library
	einfo "Building the native library"
	eant ${extraArgs} library.native.qmake library.native.compile

	# Step 3, Build the Java library
	einfo "Building the Java library"
	eant ${extraArgs} library.java

	# Step 4, Build the Examples
	use examples && einfo "Building Examples" && eant ${extraArgs} examples

	# Step 5, Build API documentation
	use doc && einfo "Generating Javadoc" && javadoc -J-Xmx128m -d javadoc -subpackages com

	# Step 6, generate start script for jambi-designer
	cat > bin/jambi-designer <<-EOF
		#! ${EPREFIX}/bin/sh
		LD_LIBRARY_PATH=${EPREFIX}/usr/lib/qt4 CLASSPATH=${EPREFIX}/usr/share/qtjambi-4/lib/qtjambi.jar:\${CLASSPATH} ${EPREFIX}/usr/bin/designer
	EOF
}

src_install() {

	# Install built jar
	java-pkg_newjar qtjambi-${MY_PV}.jar

	# Install examples jar
	use examples && java-pkg_newjar qtjambi-examples-${MY_PV}.jar ${PN}-examples.jar

	# Install designer plugins
	insinto "/usr/$(get_libdir)/qt4/plugins/designer"
	insopts -m0755
	doins plugins/designer/*$(get_libname)

	# Install native library
	#java-pkg_doso "${S}"/lib/* # does not work see #251500
	java-pkg_doso "${S}"/lib/*$(get_libname 1.0.0) "${S}"/lib/*$(get_libname 1.0) "${S}"/lib/*$(get_libname 1) "${S}"/lib/*$(get_libname) # works

	# Install sources
	use source && java-pkg_dosrc "${S}"/com

	# Install javadoc
	use doc && java-pkg_dojavadoc "${S}"/javadoc

	# Install other documentation
	use doc && dohtml "${S}"/readme.html

	# Install examples
	use examples && java-pkg_doexamples "${S}"/com/trolltech/examples

	# Install launcher-scripts
	dobin "${S}"/bin/*
	use examples && java-pkg_dolauncher jambi --main com.trolltech.launcher.Launcher \
		--java_args "-Djava.library.path=${EPREFIX}/usr/$(get_libdir)/qt4:${EPREFIX}/usr/$(get_libdir)/qtjambi-4"
}
