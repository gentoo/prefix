# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/app-office/openoffice-bin/openoffice-bin-2.4.0.ebuild,v 1.2 2008/04/17 21:50:29 maekke Exp $

EAPI="prefix"

inherit eutils fdo-mime rpm multilib

IUSE="gnome java kde"

BUILDID="9286"
MY_PV="${PV}rc6"
MY_PV2="${MY_PV}_20080314"
MY_PV3="${PV/_rc6/}-${BUILDID}"
PACKED="OOH680_m12_native_packed-1"
S="${WORKDIR}/${PACKED}_en-US.${BUILDID}/RPMS"
DESCRIPTION="OpenOffice productivity suite"

SRC_URI="mirror://openoffice/stable/${PV}/OOo_${PV}_LinuxIntel_install_en-US.tar.gz"

LANGS="af as_IN be_BY bg br bs ca cs da de dz el en en_GB en_ZA es et fi fr ga gl gu he hi_IN hr hu it ja ka km ko lt mk ml_IN mr_IN nb ne nl nn nr ns or_IN pa_IN pl pt rw sh sk sl sr ss st sv sw_TZ ta te_IN tg th ti_ER tr ts uk ur_IN ve vi xh zh_CN zh_TW zu"

for X in ${LANGS} ; do
	[[ ${X} != "en" ]] && SRC_URI="${SRC_URI} linguas_${X}? ( mirror://openoffice-extended/${MY_PV}/OOo_${MY_PV2}_LinuxIntel_langpack_${X/_/-}.tar.gz )"
	IUSE="${IUSE} linguas_${X}"
done

HOMEPAGE="http://www.openoffice.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"

#glibc removed from RDEPEND for prefix, can be assumed host OS has glibc
RDEPEND="!app-office/openoffice
	x11-libs/libXaw
	>=dev-lang/perl-5.0
	app-arch/zip
	app-arch/unzip
	>=media-libs/freetype-2.1.10-r2
	>=app-admin/eselect-oodict-20060706
	java? ( !amd64? ( >=virtual/jre-1.4 )
		amd64? ( app-emulation/emul-linux-x86-java ) )
	amd64? ( >=app-emulation/emul-linux-x86-xlibs-1.0 )
	linguas_ja? ( >=media-fonts/kochi-substitute-20030809-r3 )
	linguas_zh_CN? ( >=media-fonts/arphicfonts-0.1-r2 )
	linguas_zh_TW? ( >=media-fonts/arphicfonts-0.1-r2 )"

DEPEND="${RDEPEND}
	sys-apps/findutils"

PROVIDE="virtual/ooo"
RESTRICT="strip"

QA_EXECSTACK="usr/$(get_libdir)/openoffice/program/*"
QA_TEXTRELS="usr/$(get_libdir)/openoffice/program/libvclplug_gen680li.so.1.1 \
	usr/$(get_libdir)/openoffice/program/python-core-2.3.4/lib/lib-dynload/_curses_panel.so \
	usr/$(get_libdir)/openoffice/program/python-core-2.3.4/lib/lib-dynload/_curses.so"

src_unpack() {

	unpack ${A}
	#added for prefix
	cp "${FILESDIR}"/{50-openoffice-bin,wrapper.in} "${T}"
	epatch "${FILESDIR}"/${PN}-prefix.patch
	eprefixify "${T}"/{50-openoffice-bin,wrapper.in}

	for i in base calc core01 core02 core03 core03u core04 core04u core05 core05u core06 core07 core08 core09 core10 draw emailmerge graphicfilter headless impress math pyuno testtool writer xsltfilter ; do
		rpm_unpack "${S}/openoffice.org-${i}-${MY_PV3}.i586.rpm"
	done

	rpm_unpack "${S}/desktop-integration/openoffice.org-freedesktop-menus-2.4-9268.noarch.rpm"

	use gnome && rpm_unpack "${S}/openoffice.org-gnome-integration-${MY_PV3}.i586.rpm"
	use kde && rpm_unpack "${S}/openoffice.org-kde-integration-${MY_PV3}.i586.rpm"
	use java && rpm_unpack "${S}/openoffice.org-javafilter-${MY_PV3}.i586.rpm"

	strip-linguas en ${LANGS}

	for i in ${LINGUAS}; do
		i="${i/_/-}"
		if [[ ${i} != "en" ]] ; then
			LANGDIR="${WORKDIR}/${PACKED}_${i}.${BUILDID}/RPMS/"
			rpm_unpack ${LANGDIR}/openoffice.org-${i}-${MY_PV3}.i586.rpm
			rpm_unpack ${LANGDIR}/openoffice.org-${i}-help-${MY_PV3}.i586.rpm
			rpm_unpack ${LANGDIR}/openoffice.org-${i}-res-${MY_PV3}.i586.rpm
		fi
	done

}

src_install () {

	#Multilib install dir magic for AMD64
	has_multilib_profile && ABI=x86
	INSTDIR="/usr/$(get_libdir)/openoffice"

	einfo "Installing OpenOffice.org into build root..."
	dodir ${INSTDIR}
	mv "${WORKDIR}"/opt/openoffice.org2.4/* "${ED}${INSTDIR}"

	#Menu entries, icons and mime-types
	cd "${ED}${INSTDIR}/share/xdg/"

	for desk in base calc draw impress math printeradmin writer; do
		mv ${desk}.desktop openoffice.org-2.4-${desk}.desktop
		sed -i -e s/openoffice.org2.4/ooffice/g openoffice.org-2.4-${desk}.desktop || die
		sed -i -e s/openofficeorg24-${desk}/ooo-${desk}/g openoffice.org-2.4-${desk}.desktop || die
		domenu openoffice.org-2.4-${desk}.desktop
		insinto /usr/share/pixmaps
		newins "${WORKDIR}/usr/share/icons/gnome/48x48/apps/openofficeorg24-${desk}.png" ooo-${desk}.png
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

	# Change user install dir
	sed -i -e s/.openoffice.org2/.ooo-2.0/g "${ED}${INSTDIR}/program/bootstraprc" || die

	# Non-java weirdness see bug #99366
	use !java && rm -f "${ED}${INSTDIR}/program/javaldx"

	# Remove the provided dictionaries, we use our own instead
	rm -f "${ED}"${INSTDIR}/share/dict/ooo/*

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
