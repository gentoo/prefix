# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ibm-jdk-bin/ibm-jdk-bin-1.6.0.9_p2-r1.ebuild,v 1.3 2012/10/05 15:17:00 ranger Exp $

EAPI="4"

inherit java-vm-2 versionator eutils

JDK_MAJOR=$(get_version_component_range 1) # Version
JDK_MINOR=$(get_version_component_range 2) # Release
LNX_MICRO=$(get_version_component_range 3) # SR
AIX_MICRO=$(get_version_component_range 4) # ?

X86_JDK_DIST=$(echo   "ibm-java-sdk-${JDK_MAJOR}.${JDK_MINOR}-${LNX_MICRO}.0-i386-archive.bin"  )
AMD64_JDK_DIST=$(echo "ibm-java-sdk-${JDK_MAJOR}.${JDK_MINOR}-${LNX_MICRO}.0-x86_64-archive.bin")
PPC_JDK_DIST=$(echo   "ibm-java-sdk-${JDK_MAJOR}.${JDK_MINOR}-${LNX_MICRO}.0-ppc-archive.bin"   )
PPC64_JDK_DIST=$(echo "ibm-java-sdk-${JDK_MAJOR}.${JDK_MINOR}-${LNX_MICRO}.0-ppc64-archive.bin" )

PPC_AIX_JDK_DIST="j${JDK_MAJOR}r${JDK_MINOR}32redist.${JDK_MAJOR}.${JDK_MINOR}.0.${AIX_MICRO}.bin"

DESCRIPTION="IBM Java SE Development Kit"
HOMEPAGE="http://www.ibm.com/developerworks/java/jdk/"

SRC_URI=""
SRC_URI+=" x86?       ( ${X86_JDK_DIST}       )"
SRC_URI+=" amd64?     ( ${AMD64_JDK_DIST}     )"
SRC_URI+=" ppc?       ( ${PPC_JDK_DIST}       )"
SRC_URI+=" ppc64?     ( ${PPC64_JDK_DIST}     )"
SRC_URI+=" ppc-aix?   ( ${PPC_AIX_JDK_DIST}   )"
#SRC_URI+=" ppc64-aix? ( ${PPC64_AIX_JDK_DIST} )"

LICENSE="
	kernel_Linux? ( IBM-J${JDK_MAJOR}.${JDK_MINOR} )
	kernel_AIX?   ( IBM-J${JDK_MAJOR}.AIX          )
"

SLOT="${JDK_MAJOR}"
KEYWORDS="-* ~amd64 ~ppc ~ppc64 ~x86 ~ppc-aix"
RESTRICT="fetch splitdebug strip"
IUSE="X alsa doc examples nsplugin odbc"

RDEPEND="
	ppc? ( =virtual/libstdc++-3.3 )
	ppc64? ( =virtual/libstdc++-3.3 )
	X? (
		x11-libs/libXi
		x11-libs/libXrender
		x11-libs/libXtst
	)
	alsa? ( media-libs/alsa-lib )
	doc? ( =dev-java/java-sdk-docs-1.${JDK_MAJOR}* )
	odbc? ( dev-db/unixODBC )"

_init_at_vars() {
	if use x86; then
		JDK_DIST=${X86_JDK_DIST}
		S="${WORKDIR}/ibm-java-i386-${JDK_MAJOR}${JDK_MINOR}"
		LINK_ARCH="intel"
		LINK_ARCH_DESC="32-bit x86"
	elif use amd64; then
		JDK_DIST=${AMD64_JDK_DIST}
		S="${WORKDIR}/ibm-java-x86_64-${JDK_MAJOR}${JDK_MINOR}"
		LINK_ARCH="amd64"
		LINK_ARCH_DESC="64-bit AMD/Opteron/EM64T"
	elif use ppc; then
		JDK_DIST=${PPC_JDK_DIST}
		S="${WORKDIR}/ibm-java-ppc-${JDK_MAJOR}${JDK_MINOR}"
		LINK_ARCH="ipseries32"
		LINK_ARCH_DESC="32-bit IBM POWER"
	elif use ppc64; then
		JDK_DIST=${PPC64_JDK_DIST}
		S="${WORKDIR}/ibm-java-ppc64-${JDK_MAJOR}${JDK_MINOR}"
		LINK_ARCH="ipseries64"
		LINK_ARCH_DESC="64-bit IBM POWER"
	elif use ppc-aix; then
		JDK_DIST=${PPC_AIX_JDK_DIST}
		S="${WORKDIR}/ibm-java-ppc-${JDK_MAJOR}${JDK_MINOR}"
		LINK_ARCH="aix32"
		LINK_ARCH_DESC="32-bit"
	fi
}

pkg_nofetch() {
	_init_at_vars

	if use ppc-aix; then
		DOWNLOADPAGE="${HOMEPAGE}aix/service.html"
		DIRECT_DOWNLOAD="dka&S_PKG=${LINK_ARCH}j${JDK_MAJOR}r${JDK_MINOR}"
	else
		DOWNLOADPAGE="${HOMEPAGE}linux/download.html"
		DIRECT_DOWNLOAD+="swg-sdk${JDK_MAJOR}v${JDK_MINOR}&&S_PKG=${LINK_ARCH}_${JDK_MAJOR}${JDK_MINOR}SR${JDK_SR}"
	fi
	DIRECT_DOWNLOAD="https://www14.software.ibm.com/webapp/iwm/web/preLogin.do?source=${DIRECT_DOWNLOAD}&S_TACT=105AGX05&S_CMP=JDK"

	# bug #125178
	ALT_DOWNLOADPAGE="${HOMEPAGE}linux/older_download.html"

	einfo "Due to license restrictions, we cannot redistribute or fetch the distfiles."
	einfo "Please visit: ${DOWNLOADPAGE}"

	if use ppc-aix; then
		einfo "Under 'Java SE Version ${JDK_MAJOR}', at ${LINK_ARCH_DESC}, 'Download now'. After confirming that"
		einfo "you agree the License, from section 'LATEST REDISTRIBUTION - .bin', download:"
	else
		einfo "Under 'Java SE Version ${JDK_MAJOR}', at ${LINK_ARCH_DESC}, 'Download now'. After confirming that"
		einfo "you agree the License, from section 'SDK, tgz package (InstallAnywhere)', download:"
	fi
	einfo "${JDK_DIST}"

	einfo "You can also use a direct link to your arch download page:"
	einfo "${DIRECT_DOWNLOAD}"
	einfo "Place the file(s) in: ${DISTDIR}"
	einfo "Then restart emerge: 'emerge --resume'"

	if use ppc-aix; then
		einfo "In case you find a newer version only, check for newer ebuilds of ${PN} or file a bug."
	else
		einfo "Note: if SR${SERVICE_RELEASE}${FP_WEB} is not available at ${DOWNLOADPAGE}"
		einfo "it may have been moved to ${ALT_DOWNLOADPAGE}. Lately that page"
		einfo "isn't updated, but the files should still available through the"
		einfo "direct link to arch download page. If it doesn't work, file a bug."
	fi
}

src_unpack() {
	_init_at_vars

	# Note from:
	# http://www-01.ibm.com/support/knowledgecenter/api/content/SSYKE2_7.0.0/com.ibm.java.lnx.70.doc/user/ia_install_unattended.html
	# Archive packages have the following known issue: installations that
	# use a response file use the default directory even if you change the
	# directory in the response file. If a previous installation exists in the
	# default directory, it is overwritten.
	#
	# So we run the self-extracting shell script to install to $WORKDIR
	# without a response file, and copy the installer file here instead.
	cp "${DISTDIR}"/${JDK_DIST} . || die

	addpredict /var/.com.zerog.registry.xml

	_JAVA_OPTIONS="-Dlax.debug.level=2 -Dlax.debug.all=true" LAX_DEBUG=1 \
	$SHELL ./${JDK_DIST} -i silent || die
}

src_prepare() {
	# bug #126105
	epatch "${FILESDIR}/${PN}-jawt.h.patch"
}

src_compile() { :; }

src_install() {
	# Copy all the files to the designated directory
	dodir /opt/${P}
	cp -pPR bin jre lib include src.zip "${ED}/opt/${P}" || die

	if use examples; then
		cp -pPR demo "${ED}"/opt/${P} || die
	fi

	if use x86 || use ppc || use ppc-aix; then
		local plugin=$(get_system_arch)
		plugin=${plugin%-aix}
		plugin="/opt/${P}/jre/plugin/${plugin}/ns7/libjavaplugin_oji.so"
		if use nsplugin; then
			install_mozilla_plugin "${plugin}"
		else
			rm "${ED}${plugin}" || die
		fi
	fi

	# Install desktop file for the Java Control Panel. Using VMHANDLE as file
	# name to prevent file collision with jre and or other slots.
	sed -e "s/\(Name=\)Java/\1 Java Control Panel for IBM JDK ${SLOT}/" \
		-e "s#Exec=.*#Exec=${EPREFIX}/opt/${P}/jre/bin/jcontrol#" \
		-e "s#Icon=.*#Icon=${EPREFIX}/opt/${P}/jre/plugin/desktop/sun_java.png#" \
		-e "/Categories/s#Application;##" \
		"${ED}"/opt/${P}/jre/plugin/desktop/sun_java.desktop \
		> "${T}"/${VMHANDLE}.desktop || die
	domenu "${T}"/${VMHANDLE}.desktop || die

	dohtml -a html,htm,HTML -r docs
	dodoc copyright notices.txt readme.txt

	set_java_env

	# a workaround to fix the BOOTCLASSPATH in our env file
	# this is not optimal, using -Xcompressedrefs would probably make it
	# expect the compressedrefs version...
	if use amd64; then
		sed -i -e "s|vm.jar|amd64/default/jclSC160/vm.jar|g" "${ED}${JAVA_VM_CONFIG_DIR}/${VMHANDLE}" || die "sed failed"
	fi
	if use ppc64; then
		sed -i -e "s|vm.jar|ppc64/default/jclSC160/vm.jar|g" "${ED}${JAVA_VM_CONFIG_DIR}/${VMHANDLE}" || die "sed failed"
	fi

	java-vm_set-pax-markings "${ED}"/opt/${P}
	java-vm_revdep-mask
	java-vm_sandbox-predict	/proc/cpuinfo /proc/self/coredump_filter /proc/self/maps
}
