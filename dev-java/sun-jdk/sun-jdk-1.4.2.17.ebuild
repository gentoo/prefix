# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/sun-jdk/sun-jdk-1.4.2.17.ebuild,v 1.3 2008/05/17 18:06:49 betelgeuse Exp $

EAPI="prefix"

JAVA_SUPPORTS_GENERATION_1="true"
inherit pax-utils java-vm-2 eutils

MY_PV=${PV%.*}_${PV##*.}
MY_PN=j2sdk
MY_P=${MY_PN}${MY_PV}
MY_PVB=${PV%.*}

At="j2sdk-${PV//./_}-linux-i586.bin"
jce_policy="jce_policy-${MY_PVB//./_}.zip"

S="${WORKDIR}/${MY_P}"
DESCRIPTION="Sun's J2SE Development Kit"
HOMEPAGE="http://java.sun.com/j2se/1.4.2/"
SRC_URI="x86? ( ${At} )
		amd64? ( ${At} )
		jce? ( ${jce_policy} )"
SLOT="1.4"
LICENSE="sun-bcla-java-vm"
KEYWORDS="~amd64-linux ~x86-linux"
# files are prestripped
RESTRICT="fetch strip"
IUSE="X alsa doc examples jce nsplugin odbc"

DEPEND="sys-apps/sed
	app-arch/unzip"

RDEPEND="
	alsa? ( media-libs/alsa-lib )
	doc? ( =dev-java/java-sdk-docs-1.4.2* )
	X? (
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/libXp
		x11-libs/libXtst
		x11-libs/libXt
		x11-libs/libX11
	)
	odbc? ( dev-db/unixODBC )"

JAVA_PROVIDE="jdbc-stdext"

DL_PREFIX="https://cds.sun.com/is-bin/INTERSHOP.enfinity/WFS/CDS-CDS_Developer-Site/en_US/-/USD/ViewProductDetail-Start?ProductRef="
DOWNLOAD_URL="${DL_PREFIX}${MY_PN}-${MY_PV}-oth-JPR@CDS-CDS_Developer"
DOWNLOAD_URL_JCE="${DL_PREFIX}7503-jce-1.4.2-oth-JPR@CDS-CDS_Developer"

QA_TEXTRELS_x86="opt/${P}/jre/lib/i386/libawt.so
	opt/${P}/jre/plugin/i386/ns4/libjavaplugin.so
	opt/${P}/jre/plugin/i386/ns610/libjavaplugin_oji.so
	opt/${P}/jre/plugin/i386/ns610-gcc32/libjavaplugin_oji.so"

pkg_nofetch() {
	einfo "Please download ${At} from:"
	einfo ${DOWNLOAD_URL}
	einfo "(first select 'Accept License', then click on 'self-extracting file'"
	einfo "under 'Linux Platform - Java(TM) 2 SDK, Standard Edition')"
	einfo "and move it to ${DISTDIR}"
	if use jce; then
		echo
		einfo "Also download ${jce_policy} from:"
		einfo ${DOWNLOAD_URL_JCE}
		einfo "Java(TM) Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy Files"
		einfo "and move it to ${DISTDIR}"
	fi
}

src_unpack() {
	if [ ! -r "${DISTDIR}/${At}" ]; then
		die "cannot read ${At}. Please check the permission and try again."
	fi
	if use jce; then
		if [ ! -r "${DISTDIR}/${jce_policy}" ]; then
			die "cannot read ${jce_policy}. Please check the permission and try again."
		fi
	fi
	#Search for the ELF Header
	testExp=$(echo -e '\0177\0105\0114\0106\0001\0001\0001')
	startAt=`grep -aonm 1 ${testExp}  ${DISTDIR}/${At} | cut -d: -f1`
	tail -n +${startAt} "${DISTDIR}/${At}" > install.sfx
	chmod +x install.sfx
	./install.sfx || die
	rm install.sfx

	if [[ -f ${S}/lib/unpack ]]; then
		UNPACK_CMD=${S}/lib/unpack
		chmod +x $UNPACK_CMD
		sed -i 's#/tmp/unpack.log#/dev/null\x00\x00\x00\x00\x00\x00#g' $UNPACK_CMD
		local PACKED_JARS="lib/tools.jar jre/lib/rt.jar jre/lib/jsse.jar \
			jre/lib/charsets.jar jre/lib/ext/localedata.jar jre/lib/plugin.jar \
			jre/javaws/javaws.jar"
		for i in $PACKED_JARS; do
			PACK_FILE=${S}/`dirname $i`/`basename $i .jar`.pack
			if [ -f ${PACK_FILE} ]; then
				echo "	unpacking: $i"
				$UNPACK_CMD ${PACK_FILE} "${S}"/$i
				rm -f ${PACK_FILE}
			fi
		done
	fi
}

src_install() {
	local dirs="bin include jre lib man"
	dodir /opt/${P}

	cp -dPR ${dirs} "${ED}/opt/${P}/"

	# Set PaX markings on all JDK/JRE executables to allow code-generation on
	# the heap by the JIT compiler.
	pax-mark srpm $(list-paxables "${ED}"/opt/${P}/{,/jre}/bin/*)

	dodoc COPYRIGHT README THIRDPARTYLICENSEREADME.txt || die
	dohtml README.html || die
	if use examples; then
		cp -pPR demo "${ED}/opt/${P}/" || die
	fi

	cp -pPR src.zip "${ED}/opt/${P}/" || die

	if use jce ; then
		# Using unlimited jce while still retaining the strong jce
		# May have repercussions when you find you cannot symlink libraries
		# in classpaths.
		cd "${ED}/opt/${P}/jre/lib/security"
		unzip "${DISTDIR}/${jce_policy}"
		mv jce unlimited-jce
		dodir /opt/${P}/jre/lib/security/strong-jce
		mv "${ED}/opt/${P}/jre/lib/security/US_export_policy.jar" \
			"${ED}/opt/${P}/jre/lib/security/strong-jce" || die
		mv "${ED}/opt/${P}/jre/lib/security/local_policy.jar" \
			"${ED}/opt/${P}/jre/lib/security/strong-jce" || die
		dosym /opt/${P}/jre/lib/security/unlimited-jce/US_export_policy.jar /opt/${P}/jre/lib/security/
		dosym /opt/${P}/jre/lib/security/unlimited-jce/local_policy.jar /opt/${P}/jre/lib/security/
	fi

	if use nsplugin; then
		local plugin_dir="ns610"
		if has_version '>=sys-devel/gcc-3.2' ; then
			plugin_dir="ns610-gcc32"
		fi

		install_mozilla_plugin /opt/${P}/jre/plugin/i386/${plugin_dir}/libjavaplugin_oji.so
	fi

	# bug #147259
	dosym ../jre/javaws/javaws /opt/${P}/bin/javaws
	dosym ../javaws/javaws /opt/${P}/jre/bin/javaws

	# create dir for system preferences
	dodir /opt/${P}/.systemPrefs
	# Create files used as storage for system preferences.
	touch "${ED}/opt/${P}/.systemPrefs/.system.lock"
	chmod 644 "${ED}/opt/${P}/.systemPrefs/.system.lock"
	touch "${ED}/opt/${P}/.systemPrefs/.systemRootModFile"
	chmod 644 "${ED}/opt/${P}/.systemPrefs/.systemRootModFile"

	# install control panel for Gnome/KDE
	sed -e "s:INSTALL_DIR/JRE_NAME_VERSION:${EPREFIX}/opt/${P}/jre:" \
		-e "s/\(Name=Java\)/\1 Control Panel ${SLOT}/" \
		"${ED}/opt/${P}/jre/plugin/desktop/sun_java.desktop" > \
		"${T}/sun_java-${SLOT}.desktop"

	domenu "${T}/sun_java-${SLOT}.desktop"

	set_java_env
	java-vm_revdep-mask
}
