# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/openoffice-bin/openoffice-bin-3.0.0_rc1.ebuild,v 1.4 2008/09/15 18:49:18 suka Exp $

EAPI="prefix"

inherit eutils fdo-mime rpm multilib

IUSE="gnome java kde"

BUILDID="9350"
MY_PV="${PV/_/}"
MY_PV2="${MY_PV}_20080904"
MY_PV3="${PV/_rc1/}-${BUILDID}"
BASIS="ooobasis3.0"

if [ "${ARCH}" = "amd64" ] ; then
	OOARCH="x86_64"
	PACKED="OOO300_m5_native_packed-2"
	PACKED2="OOO300_m5_native_packed-2"
else
	OOARCH="i586"
	PACKED="OOO300_m5_native_packed-3"
	PACKED2="OOO300_m5_native_packed-2"
fi

S="${WORKDIR}/${PACKED}_en-US.${BUILDID}/RPMS"
DESCRIPTION="OpenOffice productivity suite"

SRC_URI="x86? ( mirror://openoffice/contrib/rc/${MY_PV}/OOo_${MY_PV2}_LinuxIntel_install_en-US.tar.gz )
	amd64? ( mirror://openoffice/contrib/rc/${MY_PV}/OOo_${MY_PV2}_LinuxX86-64_install_en-US.tar.gz )"

LANGS="af ar as_IN be_BY bg br bs ca cs da de dz el en en_GB en_ZA es et fi fr ga gu he hi_IN hr hu it ja ka km ko lt mk ml_IN mr_IN nb ne nl nn nr ns or_IN pa_IN pl pt rw sh sk sl sr ss st sv sw_TZ ta te_IN tg th ti_ER tr ts uk ur_IN ve vi xh zh_CN zh_TW zu"

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
	>=app-admin/eselect-oodict-20060706
	java? ( >=virtual/jre-1.5 )
	linguas_ja? ( >=media-fonts/kochi-substitute-20030809-r3 )
	linguas_zh_CN? ( >=media-fonts/arphicfonts-0.1-r2 )
	linguas_zh_TW? ( >=media-fonts/arphicfonts-0.1-r2 )"

DEPEND="${RDEPEND}
	sys-apps/findutils"

PROVIDE="virtual/ooo"
RESTRICT="strip"

QA_EXECSTACK="usr/$(get_libdir)/openoffice/basis3.0/program/*"
QA_TEXTRELS="usr/$(get_libdir)/openoffice/basis3.0/program/libvclplug_genli.so \
	usr/$(get_libdir)/openoffice/basis3.0/program/python-core-2.3.4/lib/lib-dynload/_curses_panel.so \
	usr/$(get_libdir)/openoffice/basis3.0/program/python-core-2.3.4/lib/lib-dynload/_curses.so \
	usr/$(get_libdir)/openoffice/ure/lib/*"

src_unpack() {

	unpack ${A}
	#added for prefix
	cp "${FILESDIR}"/{50-openoffice-bin,wrapper.in} "${T}"
	epatch "${FILESDIR}"/${PN}-prefix.patch
	eprefixify "${T}"/{50-openoffice-bin,wrapper.in}

	for i in base binfilter calc core01 core02 core03 core04 core05 core06 core07 draw graphicfilter images impress math ooofonts ooolinguistic pyuno testtool writer xsltfilter ; do
		rpm_unpack "${S}/${BASIS}-${i}-${MY_PV3}.${OOARCH}.rpm"
	done

	for j in base calc draw impress math writer; do
		rpm_unpack "${S}/openoffice.org3-${j}-${MY_PV3}.${OOARCH}.rpm"
	done

	rpm_unpack "${S}/openoffice.org3-${MY_PV3}.${OOARCH}.rpm"
	rpm_unpack "${S}/openoffice.org-ure-1.4.0-${BUILDID}.${OOARCH}.rpm"

	rpm_unpack "${S}/desktop-integration/openoffice.org3.0-freedesktop-menus-3.0-${BUILDID}.noarch.rpm"

	use gnome && rpm_unpack "${S}/${BASIS}-gnome-integration-${MY_PV3}.${OOARCH}.rpm"
	use kde && rpm_unpack "${S}/${BASIS}-kde-integration-${MY_PV3}.${OOARCH}.rpm"
	use java && rpm_unpack "${S}/${BASIS}-javafilter-${MY_PV3}.${OOARCH}.rpm"

	strip-linguas ${LANGS}

	if [[ -z "${LINGUAS}" ]]; then
		export LINGUAS="en"
	fi

	for k in ${LINGUAS}; do
		i="${k/_/-}"
		if [[ ${i} = "en" ]] ; then
			i="en-US"
			LANGDIR="${WORKDIR}/${PACKED}_${i}.${BUILDID}/RPMS/"
		else
			LANGDIR="${WORKDIR}/${PACKED2}_${i}.${BUILDID}/RPMS/"
		fi
		rpm_unpack ${LANGDIR}/${BASIS}-${i}-${MY_PV3}.${OOARCH}.rpm
		rpm_unpack ${LANGDIR}/openoffice.org3-${i}-${MY_PV3}.${OOARCH}.rpm
		for j in base binfilter calc draw help impress math res writer; do
			rpm_unpack ${LANGDIR}/${BASIS}-${i}-${j}-${MY_PV3}.${OOARCH}.rpm
		done
	done

}

src_install () {

	#Multilib install dir magic for AMD64
	has_multilib_profile && ABI=${ARCH}
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

	insinto /usr/share/mime/packages
	doins "${WORKDIR}/usr/share/mime/packages/openoffice.org.xml"

	# Install prefix patched wrapper script from ${T}
	newbin "${T}/wrapper.in" ooffice
	sed -i -e s/LIBDIR/$(get_libdir)/g "${ED}/usr/bin/ooffice" || die

	# Component symlinks
	for app in base calc draw impress math writer; do
		dosym ${INSTDIR}/program/s${app} /usr/bin/oo${app}
	done

	dosym ${INSTDIR}/program/spadmin.bin /usr/bin/ooffice-printeradmin
	dosym ${INSTDIR}/program/soffice /usr/bin/soffice

	rm -f ${INSTDIR}/basis-link || die
	dosym ${INSTDIR}/basis3.0 ${INSTDIR}/basis-link

	# Change user install dir
	sed -i -e "s/.openoffice.org\/3/.ooo3/g" "${ED}${INSTDIR}/program/bootstraprc" || die

	# Non-java weirdness see bug #99366
	use !java && rm -f "${ED}${INSTDIR}/program/javaldx"

	# prevent revdep-rebuild from attempting to rebuild all the time
	insinto /etc/revdep-rebuild && doins "${T}/50-openoffice-bin"

}

pkg_postinst() {

	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update

	eselect oodict update --libdir $(get_libdir)

	[[ -x /sbin/chpax ]] && [[ -e /usr/$(get_libdir)/openoffice/program/soffice.bin ]] && chpax -zm /usr/$(get_libdir)/openoffice/program/soffice.bin

	elog " To start OpenOffice.org, run:"
	elog
	elog " $ ooffice"
	elog
	elog " Also, for individual components, you can use any of:"
	elog
	elog " oobase, oocalc, oodraw, ooimpress, oomath, or oowriter"
	elog
	elog " Spell checking is now provided through our own myspell-ebuilds, "
	elog " if you want to use it, please install the correct myspell package "
	elog " according to your language needs. "

}
