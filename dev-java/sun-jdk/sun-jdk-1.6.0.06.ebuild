# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/sun-jdk/sun-jdk-1.6.0.06.ebuild,v 1.3 2008/05/22 20:34:05 maekke Exp $

EAPI="prefix"

inherit versionator java-vm-2 eutils pax-utils

UPDATE="$(get_version_component_range 4)"
UPDATE="${UPDATE#0}"
MY_PV="$(get_version_component_range 2)u${UPDATE}"
X86_AT="jdk-${MY_PV}-dlj-linux-i586.bin"
AMD64_AT="jdk-${MY_PV}-dlj-linux-amd64.bin"
SOL_X86_AT="jdk-${MY_PV}-dlj-solaris-i586.sh"
SOL_AMD64_AT="jdk-${MY_PV}-dlj-solaris-amd64.sh"
SOL_SPARC_AT="jdk-${MY_PV}-dlj-solaris-sparc.sh"
SOL_SPARCv9_AT="jdk-${MY_PV}-dlj-solaris-sparcv9.sh"

DESCRIPTION="Sun's J2SE Development Kit, version ${PV}"
HOMEPAGE="http://java.sun.com/javase/6/"
URL_BASE="http://download.java.net/dlj/binaries"
SRC_URI="x86? ( ${URL_BASE}/${X86_AT} )
		amd64? ( ${URL_BASE}/${AMD64_AT} )
		x86-solaris? ( ${URL_BASE}/${SOL_X86_AT} )
		x64-solaris? ( ${URL_BASE}/${SOL_X86_AT} ${URL_BASE}/${SOL_AMD64_AT} )
		sparc-solaris? ( ${URL_BASE}/${SOL_SPARC_AT} )
		sparc64-solaris? ( ${URL_BASE}/${SOL_SPARC_AT} ${URL_BASE}/${SOL_SPARCv9_AT} )"
SLOT="1.6"
LICENSE="dlj-1.1"
KEYWORDS="~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
RESTRICT="strip"
IUSE="X alsa doc examples jce nsplugin odbc"

QA_TEXTRELS_x86="opt/${P}/jre/lib/i386/motif21/libmawt.so
	opt/${P}/jre/lib/i386/libdeploy.so
	opt/${P}/jre/lib/i386/client/libjvm.so
	opt/${P}/jre/lib/i386/server/libjvm.so"

DEPEND="jce? ( =dev-java/sun-jce-bin-1.6.0* )"
RDEPEND="doc? ( =dev-java/java-sdk-docs-1.6.0* )
	!prefix? ( x86? ( =virtual/libstdc++-3.3 ) )
	kernel_linux? ( !prefix? ( sys-libs/glibc ) )
	alsa? ( media-libs/alsa-lib )
	X? (
			x11-libs/libXext
			x11-libs/libXi
			x11-libs/libXp
			x11-libs/libXtst
			amd64? ( x11-libs/libXt )
			x11-libs/libX11
	)
	odbc? ( dev-db/unixODBC )"

JAVA_PROVIDE="jdbc-stdext jdbc-rowset"

S="${WORKDIR}/jdk$(replace_version_separator 3 _)"

src_unpack() {
	if [[ ${CHOST} == *-solaris* ]] ; then
		for i in ${A}; do
			rm -f "${S}"/jre/{LICENSE,README} "${S}"/{LICENSE,README.html}
			sh "${DISTDIR}"/${i} --accept-license --unpack || die "Failed to unpack"
		done
	else 
		sh ${DISTDIR}/${A} --accept-license --unpack || die "Failed to unpack"
	fi

	cp "${FILESDIR}"/fontconfig.Gentoo.properties "${T}"/
	cd "${T}"
	epatch "${FILESDIR}"/fontconfig.Gentoo.properties-prefix.patch
}

src_compile() {
	# Set PaX markings on all JDK/JRE executables to allow code-generation on
	# the heap by the JIT compiler. This needs to be done before CDS - #215225
	pax-mark m $(list-paxables "${S}"{,/jre}/bin/*)

	# see bug #207282
	if use x86; then
		einfo "Creating the Class Data Sharing archives"
		"${S}"/bin/java -client -Xshare:dump || die
		"${S}"/bin/java -server -Xshare:dump || die
	fi
}

src_install() {
	local dirs="bin include jre lib man"

	dodir /opt/${P}

	cp -pPR $dirs "${ED}/opt/${P}/" || die "failed to copy"
	dodoc COPYRIGHT || die
	dohtml README.html || die

	cp -pP src.zip "${ED}/opt/${P}/" || die

	if use examples; then
		cp -pPR demo sample "${ED}/opt/${P}/" || die
	fi

	if use jce; then
		cd "${ED}/opt/${P}/jre/lib/security"
		dodir /opt/${P}/jre/lib/security/strong-jce
		mv "${ED}"/opt/${P}/jre/lib/security/US_export_policy.jar \
			"${ED}"/opt/${P}/jre/lib/security/strong-jce || die
		mv "${ED}"/opt/${P}/jre/lib/security/local_policy.jar \
			"${ED}"/opt/${P}/jre/lib/security/strong-jce || die
		dosym /opt/sun-jce-bin-1.6.0/jre/lib/security/unlimited-jce/US_export_policy.jar /opt/${P}/jre/lib/security/
		dosym /opt/sun-jce-bin-1.6.0/jre/lib/security/unlimited-jce/local_policy.jar /opt/${P}/jre/lib/security/
	fi

	if use nsplugin; then
		local plugin_dir="ns7-gcc29"
		if has_version '>=sys-devel/gcc-3' ; then
			plugin_dir="ns7"
		fi

		if use x86 ; then
			install_mozilla_plugin /opt/${P}/jre/plugin/i386/$plugin_dir/libjavaplugin_oji.so
		else
			eerror "No plugin available for amd64 arch"
		fi
	fi

	# create dir for system preferences
	dodir /opt/${P}/jre/.systemPrefs
	# Create files used as storage for system preferences.
	touch "${ED}"/opt/${P}/jre/.systemPrefs/.system.lock
	chmod 644 "${ED}"/opt/${P}/jre/.systemPrefs/.system.lock
	touch "${ED}"/opt/${P}/jre/.systemPrefs/.systemRootModFile
	chmod 644 "${ED}"/opt/${P}/jre/.systemPrefs/.systemRootModFile

	if [[ -f "${ED}"/opt/${P}/jre/plugin/desktop/sun_java.desktop ]]; then
		# install control panel for Gnome/KDE
		# The jre also installs these so make sure that they do not have the same
		# Name
		sed -e "s/\(Name=\)Java/\1 Java Control Panel for Sun JDK ${SLOT}/" \
			-e "s#Exec=.*#Exec=/opt/${P}/jre/bin/ControlPanel#" \
			-e "s#Icon=.*#Icon=/opt/${P}/jre/plugin/desktop/sun_java.png#" \
			"${ED}"/opt/${P}/jre/plugin/desktop/sun_java.desktop > \
			"${T}"/sun_jdk-${SLOT}.desktop

		domenu "${T}"/sun_jdk-${SLOT}.desktop
	fi

	# bug #56444
	insinto /opt/${P}/jre/lib/
	newins "${T}"/fontconfig.Gentoo.properties fontconfig.properties

	set_java_env
	java-vm_revdep-mask
}

pkg_postinst() {
	# Set as default VM if none exists
	java-vm-2_pkg_postinst

	elog "Please reinstall eclipse-sdk if you have it installed and want"
	elog "workaround for bug #215150."
}
