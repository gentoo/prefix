# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/openoffice-bin/openoffice-bin-3.2.0.ebuild,v 1.6 2010/03/08 18:14:42 rich0 Exp $

EAPI="2"

inherit eutils fdo-mime rpm multilib prefix

IUSE="gnome java kde"

BUILDID="9483"
BUILDID2="9472"
UREVER="1.6.0"
MY_PV="${PV}rc5"
MY_PV2="${MY_PV}_20100203"
MY_PV3="${PV}-${BUILDID}"
BASIS="ooobasis3.2"
MST="OOO320_m12"

if [ "${ARCH}" = "amd64" ] ; then
	OOARCH="x86_64"
	PACKED="${MST}_native_packed-1"
	PACKED2="${MST}_native_packed-1"
else
	OOARCH="i586"
	PACKED="${MST}_native_packed-1"
	PACKED2="${MST}_native_packed-1"
fi

S="${WORKDIR}"
UP="${PACKED}_en-US.${BUILDID}/RPMS"
DESCRIPTION="OpenOffice productivity suite"

SRC_URI="x86? ( mirror://openoffice/stable/${PV}/OOo_${PV}_LinuxIntel_install_en-US.tar.gz )
	amd64? ( mirror://openoffice/stable/${PV}/OOo_${PV}_LinuxX86-64_install_wJRE_en-US.tar.gz  )"

LANGS="ar as ast bg bn ca cs da de dz el en en_GB eo es et eu fi fr ga gl gu hi_IN hu id is it ja ka km kn ko ku lt lv mk ml mr my nb nl nn oc om or pa_IN pl pt pt_BR ro ru sh si sk sl sr sv ta te th tr ug uk uz vi zh_CN zh_TW"

for X in ${LANGS} ; do
	[[ ${X} != "en" ]] && SRC_URI="${SRC_URI} linguas_${X}? (
		x86? ( mirror://openoffice-extended/${MY_PV}/OOo_${MY_PV2}_LinuxIntel_langpack_${X/_/-}.tar.gz )
		amd64? ( mirror://openoffice-extended/${MY_PV}/OOo_${MY_PV2}_LinuxX86-64_langpack_${X/_/-}.tar.gz ) )"
	IUSE="${IUSE} linguas_${X}"
done

HOMEPAGE="http://www.openoffice.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"

RDEPEND="!app-office/openoffice
	x11-libs/libXaw
	!prefix? ( sys-libs/glibc )
	>=dev-lang/perl-5.0
	app-arch/zip
	app-arch/unzip
	>=media-libs/freetype-2.1.10-r2
	java? ( >=virtual/jre-1.5 )
	linguas_ja? ( >=media-fonts/kochi-substitute-20030809-r3 )
	linguas_zh_CN? ( >=media-fonts/arphicfonts-0.1-r2 )
	linguas_zh_TW? ( >=media-fonts/arphicfonts-0.1-r2 )"

DEPEND="${RDEPEND}
	sys-apps/findutils"

PROVIDE="virtual/ooo"
RESTRICT="strip"

QA_EXECSTACK="usr/$(get_libdir)/openoffice/basis3.2/program/*
	usr/$(get_libdir)/openoffice/ure/lib/*"
QA_TEXTRELS="usr/$(get_libdir)/openoffice/basis3.2/program/libvclplug_genli.so \
	usr/$(get_libdir)/openoffice/basis3.2/program/python-core-2.3.4/lib/lib-dynload/_curses_panel.so \
	usr/$(get_libdir)/openoffice/basis3.2/program/python-core-2.3.4/lib/lib-dynload/_curses.so \
	usr/$(get_libdir)/openoffice/ure/lib/*"

src_unpack() {

	unpack ${A}
	#added for prefix
	cp "${FILESDIR}"/{50-openoffice-bin,wrapper.in} "${T}"
	sed -i 's:/usr:@GENTOO_PORTAGE_EPREFIX@/usr:g' "${T}"/{50-openoffice-bin,wrapper.in} || die
	eprefixify "${T}"/{50-openoffice-bin,wrapper.in}

	cd "${S}"

	for i in base binfilter calc core01 core02 core03 core04 core05 core06 core07 draw graphicfilter images impress math ooofonts oooimprovement ooolinguistic pyuno testtool writer xsltfilter ; do
		rpm_unpack "./${UP}/${BASIS}-${i}-${MY_PV3}.${OOARCH}.rpm"
	done

	for j in base calc draw impress math writer; do
		rpm_unpack "./${UP}/openoffice.org3-${j}-${MY_PV3}.${OOARCH}.rpm"
	done

	rpm_unpack "./${UP}/openoffice.org3-${MY_PV3}.${OOARCH}.rpm"
	rpm_unpack "./${UP}/openoffice.org-ure-${UREVER}-${BUILDID}.${OOARCH}.rpm"

	rpm_unpack "./${UP}/desktop-integration/openoffice.org3.2-freedesktop-menus-3.2-${BUILDID2}.noarch.rpm"

	use gnome && rpm_unpack "./${UP}/${BASIS}-gnome-integration-${MY_PV3}.${OOARCH}.rpm"
	use kde && rpm_unpack "./${UP}/${BASIS}-kde-integration-${MY_PV3}.${OOARCH}.rpm"
	use java && rpm_unpack "./${UP}/${BASIS}-javafilter-${MY_PV3}.${OOARCH}.rpm"

	# Unpack provided dictionaries, unless there is a better solution...
	rpm_unpack "./${UP}/openoffice.org3-dict-en-${MY_PV3}.${OOARCH}.rpm"
	rpm_unpack "./${UP}/openoffice.org3-dict-es-${MY_PV3}.${OOARCH}.rpm"
	rpm_unpack "./${UP}/openoffice.org3-dict-fr-${MY_PV3}.${OOARCH}.rpm"

	strip-linguas ${LANGS}

	if [[ -z "${LINGUAS}" ]]; then
		export LINGUAS="en"
	fi

	for k in ${LINGUAS}; do
		i="${k/_/-}"
		if [[ ${i} = "en" ]] ; then
			i="en-US"
			LANGDIR="${PACKED}_${i}.${BUILDID}/RPMS/"
		else
			LANGDIR="${PACKED2}_${i}.${BUILDID}/RPMS/"
		fi
		rpm_unpack "./${LANGDIR}/${BASIS}-${i}-${MY_PV3}.${OOARCH}.rpm"
		rpm_unpack "./${LANGDIR}/openoffice.org3-${i}-${MY_PV3}.${OOARCH}.rpm"
		for j in base binfilter calc draw help impress math res writer; do
			rpm_unpack "./${LANGDIR}/${BASIS}-${i}-${j}-${MY_PV3}.${OOARCH}.rpm"
		done
	done

}

src_install () {

	INSTDIR="/usr/$(get_libdir)/openoffice"

	einfo "Installing OpenOffice.org into build root..."
	dodir ${INSTDIR}
	mv "${WORKDIR}"/opt/openoffice.org/* "${ED}${INSTDIR}" || die
	mv "${WORKDIR}"/opt/openoffice.org3/* "${ED}${INSTDIR}" || die

	#Menu entries, icons and mime-types
	cd "${ED}${INSTDIR}/share/xdg/"

	for desk in base calc draw impress math printeradmin qstart writer; do
		mv ${desk}.desktop openoffice.org-${desk}.desktop
		sed -i -e s/openoffice.org3/ooffice/g openoffice.org-${desk}.desktop || die
		sed -i -e s/openofficeorg3-${desk}/ooo-${desk}/g openoffice.org-${desk}.desktop || die
		domenu openoffice.org-${desk}.desktop
		insinto /usr/share/pixmaps
		if [ "${desk}" != "qstart" ] ; then
			newins "${WORKDIR}/usr/share/icons/gnome/48x48/apps/openofficeorg3-${desk}.png" ooo-${desk}.png
		fi
	done

	# Make sure the permissions are right
	fowners -R root:0 /

	# Install wrapper script
	newbin "${T}/wrapper.in" ooffice
	sed -i -e s/LIBDIR/$(get_libdir)/g "${ED}/usr/bin/ooffice" || die

	# Component symlinks
	for app in base calc draw impress math writer; do
		dosym ${INSTDIR}/program/s${app} /usr/bin/oo${app}
	done

	dosym ${INSTDIR}/program/spadmin /usr/bin/ooffice-printeradmin
	dosym ${INSTDIR}/program/soffice /usr/bin/soffice

	rm -f "${ED}${INSTDIR}/basis-link" || die
	dosym ${INSTDIR}/basis3.2 ${INSTDIR}/basis-link

	# Change user install dir
	sed -i -e "s/.openoffice.org\/3/.ooo3/g" "${ED}${INSTDIR}/program/bootstraprc" || die

	# Non-java weirdness see bug #99366
	use !java && rm -f "${ED}${INSTDIR}/ure/bin/javaldx"

	# prevent revdep-rebuild from attempting to rebuild all the time
	insinto /etc/revdep-rebuild && doins "${T}/50-openoffice-bin"

}

pkg_postinst() {

	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update

	[[ -x "${EPREFIX}"/sbin/chpax ]] && [[ -e "${EPREFIX}"/usr/$(get_libdir)/openoffice/program/soffice.bin ]] && chpax -zm "${EPREFIX}"/usr/$(get_libdir)/openoffice/program/soffice.bin

	elog " openoffice-bin does not provide integration with system spell "
	elog " dictionaries. Please install them manually through the Extensions "
	elog " Manager (Tools > Extensions Manager) or use the source based "
	elog " package instead. "
	elog
	elog " Dictionaries for english, french and spanish are provided in "
	elog " ${EPREFIX}/usr/$(get_libdir)/openoffice/share/extension/install "
	elog " Other dictionaries can be found at Suns extension site. "
	elog

}
