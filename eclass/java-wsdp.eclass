# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/java-wsdp.eclass,v 1.6 2007/01/20 17:40:26 nelchael Exp $

#
# Original Author: Krzysiek Pawlik <nelchael@gentoo.org>
# Purpose: Automate installation of Sun's JWSDP components
#

inherit java-pkg-2

EXPORT_FUNCTIONS src_unpack src_install pkg_nofetch pkg_setup

JWSDP_VERSION="${JWSDP_VERSION/./_}"
JWSDP_PKG="${PN/sun-/}"
JWSDP_PKG="${JWSDP_PKG/-bin/}"

DESCRIPTION="Sun's Java Web Services Developer Pack - ${JWSDP_DESC} (${JWSDP_PKG})"
HOMEPAGE="http://java.sun.com/webservices/jwsdp/"
SRC_URI="jwsdp-${JWSDP_VERSION}-unix.sh"
LICENSE="sun-jwsdp"
SLOT="0"
RESTRICT="fetch nostrip"

IUSE="doc"

# java-utils-2.eclass currently only does vm switching if you DEPEND
# on virtual/jdk so we need to depend on that to get right version of java
# in src_unpack
DEPEND="
	>=virtual/jdk-1.5
	app-arch/unzip"
RDEPEND=">=virtual/jre-1.5
	${RDEPEND}"

java-wsdp_pkg_nofetch() {

	einfo "Please go to following URL:"
	einfo " ${HOMEPAGE}"
	einfo "download file named jwsdp-${JWSDP_VERSION}-unix.sh and place it in:"
	einfo " ${DISTDIR}"

}

java-wsdp_pkg_setup() {

	# JWSDP version is a version for *whole* pack! Each component has it's own
	# version, so we have to know also the JWSDP version:
	[[ -z "${JWSDP_VERSION}" ]] && die "No JWSDP version given."

	java-pkg-2_pkg_setup
}

# The file downloaded from Sun is self-extracting archive, it uses obsolete
# `tail +<number>` syntax, and... breaks, so:
java-wsdp_src_unpack() {

	ebegin "Extracting zip file"
	mkdir "${T}/unpacked" || die "mkdir failed"

	# This tries to figure out right offset from `tail +<number>`:
	offset="`grep -a '^tail +' ${DISTDIR}/${A} | sed -e 's/.*+\([0-9]\+\).*/\1/'`"

	# Get the archive from .sh file:
	tail -n +${offset} "${DISTDIR}/${A}" > "${T}/unpacked/packed.zip" || \
		die	"tail failed"

	# And finally unpack it:
	cd "${T}/unpacked/"
	unpack "./packed.zip"
	eend 0

	# Now the Sun's installer is run to get the files:
	ebegin "Installing using Sun's installer, please wait"
	cd "${T}/unpacked/"
	mkdir -p "${T}/fakehome" || die "mkdir failed"
	java -Duser.home="${T}/fakehome" JWSDP -silent -P installLocation="${WORKDIR}/base" || die "java failed"
	eend 0

	# A little cleanup (remove unneeded files like uninstaller, images for it,
	# bundled ant):
	cd "${WORKDIR}/base"
	rm -fr _uninst uninstall.sh images apache-ant

}

java-wsdp_src_install() {

	cd "${WORKDIR}/base/${JWSDP_PKG}"

	# Remove existing compiled jars that belong to other packages (ebuild has to
	# define REMOVE_JARS="jar 1 jar2" without ".jar" extension. All jars in
	# lib/endorsed/ are ignored:
	for i in ${REMOVE_JARS}; do
		rm -f lib/${i}.jar
	done

	java-pkg_dojar lib/*.jar

	if use doc; then
		[[ -d docs ]] && java-pkg_dohtml -r docs/*
	fi

}
