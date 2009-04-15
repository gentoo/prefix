# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/sun-jdk/sun-jdk-1.6.0.07-r1.ebuild,v 1.1 2008/09/09 14:00:30 betelgeuse Exp $

inherit versionator eutils

UPDATE="$(get_version_component_range 4)"
UPDATE="${UPDATE#0}"
MY_PV="$(get_version_component_range 2)u${UPDATE}"

DESCRIPTION="Sun's J2SE Development Kit, version ${PV}"
HOMEPAGE="http://java.sun.com/javase/6/"

# the winnt source file is a repackage of a normal windows installation.
# the normal sdk setup .exe was installed with this command line:
# jdk-6u7-windows-i586-p.exe /s /v "/qn ADDLOCAL=ToolsFeature,DemosFeature INSTALLDIR=C:\java\jdk1.6.0_07 REBOOT=SUPPRESS"
# then the C:\java\jdk1.6.0_07 dir was added to a bz2 and thats it...
SRC_URI="http://dev.gentoo.org/~mduft/java/jdk$(replace_version_separator 3 _)-windows-i586.tar.bz2"
LICENSE="dlj-1.1"

# WARNING: windows JDK not slotted for now, since we cannot use java-config
SLOT="0"
KEYWORDS="-* ~x86-winnt"
RESTRICT="strip"
IUSE="doc examples"

RDEPEND="doc? ( =dev-java/java-sdk-docs-1.6.0* )"
JAVA_PROVIDE="jdbc-stdext jdbc-rowset"

S="${WORKDIR}/jdk$(replace_version_separator 3 _)"

src_install() {
	local dirs="bin include jre lib"
	local javadir=/usr

	dodir ${javadir}

	cp -pPR $dirs "${ED}${javadir}/" || die "failed to copy"
	dodoc COPYRIGHT || die
	dohtml README.html || die

	# not necessarily there.
	if [[ -f src.zip ]]; then
		cp -pP src.zip "${ED}${javadir}/" || die
	fi

	if use examples; then
		cp -pPR demo sample "${ED}${javadir}" || die
	fi

	echo > "${T}"/java-win32-gui.sh <<EOF
#!/bin/env bash
executable=
case "\$0" in
/*) executable=\$(unixpath2win \$0.exe) ;;
*) executable=\$0.exe ;;
esac

runwin32 \$executable
EOF

	into /usr
	dobin "${T}"/java-win32-gui.sh

	# for easy work from command lines, create links to .exe files:
	for x in $(find "${ED}" -name '*.exe'); do
		if file ${x} | grep "GUI" > /dev/null 2>&1; then
			# don't create a link, but rather create a small wrapper calling
			# runwin32.
			ln -sf java-win32-gui.sh "${x%.exe}"
		else
			ln -sf "$(basename "${x}")" "${x%.exe}"
		fi
	done

	ln -sf ../../bin/java-win32-gui.sh "${ED}${javadir}"/jre/bin/java-win32-gui.sh

	echo "JDK_HOME=${EPREFIX}${javadir}" >> "${T}"/98winjdk.env
	echo "JAVA_HOME=${EPREFIX}${javadir}" >> "${T}"/98winjdk.env
	echo "JAVAC=javac" >> "${T}"/98winjdk.env

	doenvd "${T}"/98winjdk.env
}
