# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/vdr-plugin.eclass,v 1.52 2007/12/12 17:43:50 zzam Exp $
#
# Author:
#   Matthias Schwarzott <zzam@gentoo.org>
#   Joerg Bornkessel <hd_brummy@gentoo.org>

# vdr-plugin.eclass
#
#   eclass to create ebuilds for vdr plugins
#

# Example ebuild (vdr-femon):
#
#	inherit vdr-plugin
#	IUSE=""
#	SLOT="0"
#	DESCRIPTION="vdr Plugin: DVB Frontend Status Monitor (signal strengt/noise)"
#	HOMEPAGE="http://www.saunalahti.fi/~rahrenbe/vdr/femon/"
#	SRC_URI="http://www.saunalahti.fi/~rahrenbe/vdr/femon/files/${P}.tgz"
#	LICENSE="GPL-2"
#	KEYWORDS="~x86"
#	DEPEND=">=media-video/vdr-1.3.27"
#
#

# Installation of a config file for the plugin
#
#     If ${VDR_CONFD_FILE} is set install this file
#     else install ${FILESDIR}/confd if it exists.

#     Gets installed as /etc/conf.d/vdr.${VDRPLUGIN}.
#     For the plugin vdr-femon this would be /etc/conf.d/vdr.femon


# Installation of an rc-addon file for the plugin
#
#     If ${VDR_RCADDON_FILE} is set install this file
#     else install ${FILESDIR}/rc-addon.sh if it exists.
#
#     Gets installed under ${VDR_RC_DIR}/plugin-${VDRPLUGIN}.sh
#     (in example vdr-femon this would be /usr/share/vdr/rcscript/plugin-femon.sh)
#
#     This file is sourced by the startscript when plugin is activated in /etc/conf.d/vdr
#     It could be used for special startup actions for this plugins, or to create the
#     plugin command line options from a nicer version of a conf.d file.

# HowTo use own local patches; Example
#
#	Add to your /etc/make.conf:
# 	VDR_LOCAL_PATCHES_DIR="/usr/local/patch"
#
#	Add two DIR's in your local patch dir, ${PN}/${PV},
#	e.g for vdr-burn-0.1.0 should be:
#	/usr/local/patch/vdr-burn/0.1.0/
#
#	all patches which ending on diff or patch in this DIR will automatically applied
#

inherit base multilib eutils flag-o-matic

IUSE=""

# Name of the plugin stripped from all vdrplugin-, vdr- and -cvs pre- and postfixes
VDRPLUGIN="${PN/#vdrplugin-/}"
VDRPLUGIN="${VDRPLUGIN/#vdr-/}"
VDRPLUGIN="${VDRPLUGIN/%-cvs/}"

DESCRIPTION="vdr Plugin: ${VDRPLUGIN} (based on vdr-plugin.eclass)"

# works in most cases
S="${WORKDIR}/${VDRPLUGIN}-${PV}"

# depend on headers for DVB-driver
DEPEND=">=media-tv/gentoo-vdr-scripts-0.3.8
	|| ( >=media-tv/gentoo-vdr-scripts-0.4.2 >=media-tv/vdrplugin-rebuild-0.2 )
	>=app-admin/eselect-vdr-0.0.2
	media-tv/linuxtv-dvb-headers"


# New method of storing plugindb
#   Called from src_install
#   file maintained by normal portage-methods
create_plugindb_file() {
	local NEW_VDRPLUGINDB_DIR=/usr/share/vdr/vdrplugin-rebuild/
	local DB_FILE="${NEW_VDRPLUGINDB_DIR}/${CATEGORY}-${PF}"
	insinto "${NEW_VDRPLUGINDB_DIR}"

#	BUG: portage-2.1.4_rc9 will delete the EBUILD= line, so we cannot use this code.
#	cat <<-EOT > "${ED}/${DB_FILE}"
#		VDRPLUGIN_DB=1
#		CREATOR=ECLASS
#		EBUILD=${CATEGORY}/${PN}
#		EBUILD_V=${PVR}
#	EOT
	{
		echo "VDRPLUGIN_DB=1"
		echo "CREATOR=ECLASS"
		echo "EBUILD=${CATEGORY}/${PN}"
		echo "EBUILD_V=${PVR}"
	} > "${ED}/${DB_FILE}"
}

# Delete files created outside of vdr-plugin.eclass
#   vdrplugin-rebuild.ebuild converted plugindb and files are
#   not deleted by portage itself - should only be needed as
#   long as not every system has switched over to
#   vdrplugin-rebuild-0.2 / gentoo-vdr-scripts-0.4.2
delete_orphan_plugindb_file() {
	#elog Testing for orphaned plugindb file
	local NEW_VDRPLUGINDB_DIR=/usr/share/vdr/vdrplugin-rebuild/
	local DB_FILE="${EROOT}/${NEW_VDRPLUGINDB_DIR}/${CATEGORY}-${PF}"

	# file exists
	[[ -f ${DB_FILE} ]] || return

	# will portage handle the file itself
	if grep -q CREATOR=ECLASS "${DB_FILE}"; then
		#elog file owned by eclass - don't touch it
		return
	fi

	elog "Removing orphaned plugindb-file."
	elog "\t#rm ${DB_FILE}"
	rm "${DB_FILE}"
}


create_header_checksum_file()
{
	# Danger: Not using $ROOT here, as compile will also not use it !!!
	# If vdr in $ROOT and / differ, plugins will not run anyway

	insinto "${VDR_CHECKSUM_DIR}"
	if [[ -f ${VDR_CHECKSUM_DIR}/header-md5-vdr ]]; then
		newins "${VDR_CHECKSUM_DIR}/header-md5-vdr header-md5-${PN}"
	else
		if type -p md5sum >/dev/null 2>&1; then
			cd "${S}"
			(
				cd "${VDR_INCLUDE_DIR}"
				md5sum *.h libsi/*.h|LC_ALL=C sort --key=2
			) > header-md5-${PN}
			doins header-md5-${PN}
		fi
	fi
}

vdr-plugin_pkg_setup() {
	# -fPIC is needed for shared objects on some platforms (amd64 and others)
	append-flags -fPIC

	# Where should the plugins live in the filesystem
	VDR_PLUGIN_DIR="/usr/$(get_libdir)/vdr/plugins"
	VDR_CHECKSUM_DIR="${VDR_PLUGIN_DIR%/plugins}/checksums"

	# was /usr/lib/... some time ago
	# since gentoo-vdr-scripts-0.3.6 it works with /usr/share/...
	VDR_RC_DIR="/usr/share/vdr/rcscript"

	# Pathes to includes
	VDR_INCLUDE_DIR="/usr/include/vdr"
	DVB_INCLUDE_DIR="/usr/include"


	TMP_LOCALE_DIR="${WORKDIR}/tmp-locale"
	LOCDIR="/usr/share/vdr/locale"
	if has_version ">=media-video/vdr-1.5.7"; then
		USE_GETTEXT=1
	else
		USE_GETTEXT=0
	fi

	VDRVERSION=$(awk -F'"' '/define VDRVERSION/ {print $2}' "${VDR_INCLUDE_DIR}"/config.h)
	APIVERSION=$(awk -F'"' '/define APIVERSION/ {print $2}' "${VDR_INCLUDE_DIR}"/config.h)
	[[ -z ${APIVERSION} ]] && APIVERSION="${VDRVERSION}"

	einfo "Building ${PF} against vdr-${VDRVERSION}"
	einfo "APIVERSION: ${APIVERSION}"
}

vdr-plugin_src_unpack() {
	if [[ -z ${VDR_INCLUDE_DIR} ]]; then
		eerror "Wrong use of vdr-plugin.eclass."
		eerror "An ebuild for a vdr-plugin will not work without calling vdr-plugin_pkg_setup."
		echo
		eerror "Please report this at bugs.gentoo.org."
		die "vdr-plugin_pkg_setup not called!"
	fi
	[ -z "$1" ] && vdr-plugin_src_unpack unpack add_local_patch patchmakefile i18n

	while [ "$1" ]; do

		case "$1" in
		all_but_unpack)
			vdr-plugin_src_unpack add_local_patch patchmakefile i18n
			;;
		unpack)
			base_src_unpack
			;;
		patchmakefile)
			if ! cd "${S}"; then
				ewarn "There seems to be no plugin-directory with the name ${S##*/}"
				ewarn "Perhaps you find one among these:"
				cd "${WORKDIR}"
				ewarn "$(/bin/ls -1 "${WORKDIR}")"
				die "Could not change to plugin-source-directory!"
			fi

			einfo "Patching Makefile"
			[[ -e Makefile ]] || die "Makefile of plugin can not be found!"
			cp Makefile "${WORKDIR}"/Makefile.before

			sed -i Makefile \
				-e '1i\#Makefile was patched by vdr-plugin.eclass'

			ebegin "  Setting Pathes"
			sed -i Makefile \
				-e "s:^VDRDIR.*$:VDRDIR = ${VDR_INCLUDE_DIR}:" \
				-e "s:^DVBDIR.*$:DVBDIR = ${DVB_INCLUDE_DIR}:" \
				-e "s:^LIBDIR.*$:LIBDIR = ${S}:" \
				-e "s:^TMPDIR.*$:TMPDIR = ${T}:" \
				-e 's:-I$(VDRDIR)/include -I$(DVBDIR)/include:-I$(DVBDIR)/include -I$(VDRDIR)/include:' \
				-e 's:-I$(VDRDIR)/include:-I'"${VDR_INCLUDE_DIR%vdr}"':' \
				-e 's:-I$(DVBDIR)/include:-I$(DVBDIR):'
			eend $?

			ebegin "  Converting to APIVERSION"
			sed -i Makefile \
				-e 's:^APIVERSION = :APIVERSION ?= :' \
				-e 's:$(LIBDIR)/$@.$(VDRVERSION):$(LIBDIR)/$@.$(APIVERSION):' \
				-e '2i\APIVERSION = '"${APIVERSION}"
			eend $?

			ebegin "  Correcting Compile-Flags"
			sed -i Makefile \
				-e 's:^CXXFLAGS:#CXXFLAGS:' \
				-e '/LDFLAGS/!s:-shared:$(LDFLAGS) -shared:'
			eend $?

			ebegin "  Disabling file stripping"
			sed -i Makefile \
				-e '/@.*strip/d' \
				-e '/strip \$(LIBDIR)\/\$@/d' \
				-e '/^STRIP =/d' \
				-e '/@.*\$(STRIP)/d'
			eend $?

			# Use a file instead of an variable as single-stepping via ebuild
			# destroys environment.
			touch ${WORKDIR}/.vdr-plugin_makefile_patched
			;;
		add_local_patch)
			cd "${S}"
			if test -d "${VDR_LOCAL_PATCHES_DIR}/${PN}"; then
				echo
				einfo "Applying local patches"
				for LOCALPATCH in "${VDR_LOCAL_PATCHES_DIR}/${PN}/${PV}"/*.{diff,patch}; do
					test -f "${LOCALPATCH}" && epatch "${LOCALPATCH}"
				done
			fi
			;;
		i18n)
			cd "${S}"
			if [[ ${USE_GETTEXT} = 0 ]]; then
				# Remove i18n Target if using older vdr
				sed -i Makefile \
					-e '/^all:/s/ i18n//'
			elif [[ ${USE_GETTEXT} = 1 && ! -d po && ${NO_GETTEXT_HACK} != 1 ]]; then
				einfo "Converting translations to gettext"

				local i18n_tool="${EROOT}/usr/share/vdr/bin/i18n-to-gettext.pl"
				if [[ ! -x ${i18n_tool} ]]; then
					eerror "Missing ${i18n_tool}"
					eerror "Please re-emerge vdr"
					die "Missing ${i18n_tool}"
				fi

				# call i18n-to-gettext tool
				# take all texts missing tr call into special file
				"${i18n_tool}" 2>/dev/null \
					|sed -e '/^"/!d' \
						-e '/^""$/d' \
						-e 's/\(.*\)/trNOOP(\1)/' \
					> dummy-translations-trNOOP.c

				# if there were untranslated texts just run it again
				# now the missing calls are listed in
				# dummy-translations-trNOOP.c
				if [[ -s dummy-translations-trNOOP.c ]]; then
					"${i18n_tool}" &>/dev/null
				fi

				# now use the modified Makefile
				mv Makefile.new Makefile
			fi
		esac

		shift
	done
}

vdr-plugin_copy_source_tree() {
	pushd . >/dev/null
	cp -r "${S}" "${T}"/source-tree
	cd "${T}"/source-tree
	cp "${WORKDIR}"/Makefile.before Makefile
	sed -i Makefile \
		-e "s:^DVBDIR.*$:DVBDIR = ${DVB_INCLUDE_DIR}:" \
		-e 's:^CXXFLAGS:#CXXFLAGS:' \
		-e 's:-I$(DVBDIR)/include:-I$(DVBDIR):' \
		-e 's:-I$(VDRDIR) -I$(DVBDIR):-I$(DVBDIR) -I$(VDRDIR):'
	popd >/dev/null
}

vdr-plugin_install_source_tree() {
	einfo "Installing sources"
	destdir="${VDRSOURCE_DIR}/vdr-${VDRVERSION}/PLUGINS/src/${VDRPLUGIN}"
	insinto "${destdir}-${PV}"
	doins -r "${T}"/source-tree/*

	dosym "${VDRPLUGIN}-${PV}" "${destdir}"
}

vdr-plugin_src_compile() {
	[ -z "$1" ] && vdr-plugin_src_compile prepare compile

	while [ "$1" ]; do

		case "$1" in
		prepare)
			[[ -n "${VDRSOURCE_DIR}" ]] && vdr-plugin_copy_source_tree
			;;
		compile)
			if [[ ! -f ${WORKDIR}/.vdr-plugin_makefile_patched ]]; then
				eerror "Wrong use of vdr-plugin.eclass."
				eerror "An ebuild for a vdr-plugin will not work without"
				eerror "calling vdr-plugin_src_unpack to patch the Makefile."
				echo
				eerror "Please report this at bugs.gentoo.org."
				die "vdr-plugin_src_unpack not called!"
			fi
			cd "${S}"

			emake ${BUILD_PARAMS} \
				${VDRPLUGIN_MAKE_TARGET:-all} \
				LOCALEDIR="${TMP_LOCALE_DIR}" \
			|| die "emake failed"
			;;
		esac

		shift
	done
}

vdr-plugin_src_install() {
	[[ -n "${VDRSOURCE_DIR}" ]] && vdr-plugin_install_source_tree
	cd "${WORKDIR}"

	if [[ -n ${VDR_MAINTAINER_MODE} ]]; then
		local mname="${P}-Makefile"
		cp "${S}"/Makefile "${mname}.patched"
		cp Makefile.before "${mname}.before"

		diff -u "${mname}.before" "${mname}.patched" > "${mname}.diff"

		insinto "/usr/share/vdr/maintainer-data/makefile-changes"
		doins "${mname}.diff"

		insinto "/usr/share/vdr/maintainer-data/makefile-before"
		doins "${mname}.before"

		insinto "/usr/share/vdr/maintainer-data/makefile-patched"
		doins "${mname}.patched"

	fi

	cd "${S}"
	insinto "${VDR_PLUGIN_DIR}"
	doins libvdr-*.so.*

	if [[ ${USE_GETTEXT} = 1 && -d ${TMP_LOCALE_DIR} ]]; then
		einfo "Installing locales"
		cd "${TMP_LOCALE_DIR}"
		insinto "${LOCDIR}"
		doins -r *
	fi

	cd "${S}"
	local docfile
	for docfile in README* HISTORY CHANGELOG; do
		[[ -f ${docfile} ]] && dodoc ${docfile}
	done

	# if VDR_CONFD_FILE is empty and ${FILESDIR}/confd exists take it
	[[ -z ${VDR_CONFD_FILE} ]] && [[ -e ${FILESDIR}/confd ]] && VDR_CONFD_FILE=${FILESDIR}/confd

	if [[ -n ${VDR_CONFD_FILE} ]]; then
		newconfd "${VDR_CONFD_FILE}" vdr.${VDRPLUGIN}
	fi


	# if VDR_RCADDON_FILE is empty and ${FILESDIR}/rc-addon.sh exists take it
	[[ -z ${VDR_RCADDON_FILE} ]] && [[ -e ${FILESDIR}/rc-addon.sh ]] && VDR_RCADDON_FILE=${FILESDIR}/rc-addon.sh

	if [[ -n ${VDR_RCADDON_FILE} ]]; then
		insinto "${VDR_RC_DIR}"
		newins "${VDR_RCADDON_FILE}" plugin-${VDRPLUGIN}.sh
	fi

	create_header_checksum_file
	create_plugindb_file
}

vdr-plugin_print_enable_command() {
	ewarn "emerge --config ${PN} is deprecated"
	elog
	elog "To activate this vdr-plugin execute the following command:"
	elog "\teselect vdr-plugin enable ${PN#vdr-}"
	elog
}

vdr-plugin_pkg_postinst() {
	vdr-plugin_print_enable_command

	if [[ -n "${VDR_CONFD_FILE}" ]]; then
		elog "Please have a look at the config-file"
		elog "\t/etc/conf.d/vdr.${VDRPLUGIN}"
		elog
	fi
}

vdr-plugin_pkg_postrm() {
	delete_orphan_plugindb_file
}

vdr-plugin_pkg_config_legacy() {
	elog "Using old interface to gentoo-vdr-scripts-0.3.7"
	if [[ -z "${INSTALLPLUGIN}" ]]; then
		INSTALLPLUGIN="${VDRPLUGIN}"
	fi

	active=0
	# First test if plugin is already inside PLUGINS
	local conf=/etc/conf.d/vdr.plugins
	exec 3<${conf}
	while read -u 3 line; do
		[[ ${line} == "" ]] && continue
		[[ ${line:0:1} == "#" ]] && continue
		set -- ${line}
		[[ ${1} == ${INSTALLPLUGIN} ]] && active=1
	done
	exec 3<&-

	if [[ $active == 0 ]]; then
		elog "Adding ${INSTALLPLUGIN} to active plugins."

		# The pure edit process.
		echo "${INSTALLPLUGIN}" >> "${conf}"
	else
		elog "${INSTALLPLUGIN} already activated"
		echo
		read -p "Do you want to deactivate ${INSTALLPLUGIN} (yes/no) " answer
		if [[ "${answer}" != "yes" ]]; then
			elog "aborted"
			return
		fi
		elog "Removing ${INSTALLPLUGIN} from active plugins."

		# The pure edit process
		sed -i "${conf}" -e "/^[[:space:]]*${INSTALLPLUGIN}[[:space:]]*\$/d"
	fi
}

vdr-plugin_pkg_config() {
	vdr-plugin_print_enable_command

	einfo "Calling this now"
	eselect vdr-plugin enable "${PN#vdr-}"
}

fix_vdr_libsi_include()
{
	einfo "Fixing include of libsi-headers"
	local f
	for f; do
		sed -i "${f}" \
			-e '/#include/s:"\(.*libsi.*\)":<\1>:' \
			-e '/#include/s:<.*\(libsi/.*\)>:<vdr/\1>:'
	done
}

EXPORT_FUNCTIONS pkg_setup src_unpack src_compile src_install pkg_postinst pkg_postrm pkg_config
