# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/java-gnome.eclass,v 1.3 2006/10/28 22:29:14 swegener Exp $

#
# Original Author: Joshua Nichols <nichoj@gentoo.org>
# Purpose:  Reduce repeated code between the java-gnome packages to
# 			to facilitate ease of maintenance.
#

# Must be before the gnome.org inherit
GNOME_TARBALL_SUFFIX=${GNOME_TARBALL_SUFFIX:=gz}
inherit java-pkg-2 eutils gnome.org


HOMEPAGE="http://java-gnome.sourceforge.net/"
LICENSE="LGPL-2.1"

IUSE="gcj doc source"
RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4
	source? ( app-arch/zip )
	dev-util/pkgconfig"

# Do some heuristics to figure out what bindings this package is for
# This may be overriden when needed from each ebuild
if [[ -z ${JAVA_GNOME_BINDINGS} ]]; then
	JAVA_GNOME_BINDINGS=${PN}
	JAVA_GNOME_BINDINGS=${JAVA_GNOME_BINDINGS/-java/}
	# skip over glib because it's too good for our heuristic
	[[ ${JAVA_GNOME_BINDINGS} != "glib" ]] &&
		JAVA_GNOME_BINDINGS=${JAVA_GNOME_BINDINGS/lib/}
fi

# Filename of the jar that will be built/installed
if [[ ${SLOT} != "0" ]]; then
	JAVA_GNOME_JARNAME="${JAVA_GNOME_BINDINGS}${SLOT}.jar"
else
	JAVA_GNOME_JARNAME="${JAVA_GNOME_BINDINGS}.jar"
fi

# Full path to installed jar
JAVA_GNOME_JARPATH="${JAVA_PKG_JARDEST}/${JARNAME}"

# pkgconfig file for the package
JAVA_GNOME_PC=${JAVA_GNOME_PC:="${JAVA_GNOME_BINDINGS}-java.pc"}

# Override arguments to econf, by calling java-gnome_src_compile
# with the extra args

java-gnome_pkg_setup() {
	java-pkg-2_pkg_setup
	use gcj && java-pkg_ensure-gcj
}

java-gnome_src_compile() {
	JNI_INCLUDES=$(java-pkg_get-jni-cflags) \
	JAVAC="javac $(java-pkg_javac-args)" econf \
		$(use_with doc javadocs) \
		$(use_with gcj gcj-compile) \
		--with-jardir=${JAVA_PKG_JARDEST} \
		"$@" || die "configure failed"

	emake || die "emake failed"

	# Fix the broken pkgconfig file
	sed -i \
		-e "s:classpath.*$:classpath=\${prefix}/share/${JAVA_PKG_NAME}/lib/${JAVA_GNOME_JARNAME}:" \
		${S}/${JAVA_GNOME_PC} || die "failed to tweak ${JAVA_NOME_PC}"
}

java-gnome_src_install() {
	emake DESTDIR=${D} install || die "install failed"

	java-pkg_regjar ${JAVA_GNOME_JARPATH}
	# Examples as documentation
	! use doc && rm -rf ${ED}/usr/share/doc/${PF}/examples

	use source && java-pkg_dosrc ${S}/src/java/*
}

EXPORT_FUNCTIONS pkg_setup src_compile src_install
