# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/vdr-plugin.eclass,v 1.43 2007/03/13 09:48:02 zzam Exp $
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
RDEPEND=">=media-tv/gentoo-vdr-scripts-0.3.4-r1"
DEPEND="media-tv/linuxtv-dvb-headers"


# this code is from linux-mod.eclass
update_vdrplugindb() {
	local VDRPLUGINDB_DIR=${EROOT}/var/lib/vdrplugin-rebuild/

	if [[ ! -f ${VDRPLUGINDB_DIR}/vdrplugindb ]]; then
		[[ ! -d ${VDRPLUGINDB_DIR} ]] && mkdir -p ${VDRPLUGINDB_DIR}
		touch ${VDRPLUGINDB_DIR}/vdrplugindb
	fi
	if [[ -z $(grep ${CATEGORY}/${PN}-${PVR} ${VDRPLUGINDB_DIR}/vdrplugindb) ]]; then
		einfo "Adding plugin to vdrplugindb."
		echo "a:1:${CATEGORY}/${PN}-${PVR}" >> ${VDRPLUGINDB_DIR}/vdrplugindb
	fi
}

remove_vdrplugindb() {
	local VDRPLUGINDB_DIR=${EROOT}/var/lib/vdrplugin-rebuild/

	if [[ -n $(grep ${CATEGORY}/${PN}-${PVR} ${VDRPLUGINDB_DIR}/vdrplugindb) ]]; then
		einfo "Removing ${CATEGORY}/${PN}-${PVR} from vdrplugindb."
		sed -ie "/.*${CATEGORY}\/${P}.*/d" ${VDRPLUGINDB_DIR}/vdrplugindb
	fi
}

# New method of storing plugindb
#   Called from src_install
#   file maintained by normal portage-methods
create_plugindb_file() {
	local NEW_VDRPLUGINDB_DIR=/usr/share/vdr/vdrplugin-rebuild/
	local DB_FILE=${NEW_VDRPLUGINDB_DIR}/${CATEGORY}-${PF}
	insinto ${NEW_VDRPLUGINDB_DIR}
	cat <<-EOT > ${ED}/${DB_FILE}
		VDRPLUGIN_DB=1
		CREATOR=ECLASS
		EBUILD=${CATEGORY}/${PN}
		EBUILD_V=${PVR}
	EOT
}

# Delete files created outside of vdr-plugin.eclass
#   vdrplugin-rebuild.ebuild converted plugindb and files are
#   not deleted by portage itself - should only be needed as
#   long as not every system has switched over to
#   vdrplugin-rebuild-0.2
delete_orphan_plugindb_file() {
	#elog Testing for orphaned plugindb file
	local NEW_VDRPLUGINDB_DIR=/usr/share/vdr/vdrplugin-rebuild/
	local DB_FILE=${EROOT}/${NEW_VDRPLUGINDB_DIR}/${CATEGORY}-${PF}

	# file exists
	[[ -f ${DB_FILE} ]] || return

	# will portage handle the file itself
	if grep -q CREATOR=ECLASS ${DB_FILE}; then
		#elog file owned by eclass - don't touch it
		return
	fi

	elog "Removing orphaned plugindb-file."
	elog "\t#rm ${DB_FILE}"
	rm ${DB_FILE}
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


	VDRVERSION=$(awk -F'"' '/define VDRVERSION/ {print $2}' ${VDR_INCLUDE_DIR}/config.h)
	APIVERSION=$(awk -F'"' '/define APIVERSION/ {print $2}' ${VDR_INCLUDE_DIR}/config.h)
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
	[ -z "$1" ] && vdr-plugin_src_unpack unpack add_local_patch patchmakefile

	while [ "$1" ]; do

		case "$1" in
		all_but_unpack)
			vdr-plugin_src_unpack add_local_patch patchmakefile
			;;
		unpack)
			base_src_unpack
			;;
		patchmakefile)
			if ! cd ${S}; then
				ewarn "There seems to be no plugin-directory with the name ${S##*/}"
				ewarn "Perhaps you find one among these:"
				cd "${WORKDIR}"
				ewarn "$(/bin/ls -1 ${WORKDIR})"
				die "Could not change to plugin-source-directory!"
			fi

			einfo "Patching Makefile"
			[[ -e Makefile ]] || die "Makefile of plugin can not be found!"
			cp Makefile Makefile.orig

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
			cd ${S}
			if test -d "${VDR_LOCAL_PATCHES_DIR}/${PN}"; then
				echo
				einfo "Applying local patches"
				for LOCALPATCH in ${VDR_LOCAL_PATCHES_DIR}/${PN}/${PV}/*.{diff,patch}; do
					test -f "${LOCALPATCH}" && epatch "${LOCALPATCH}"
				done
			fi
			;;
		esac

		shift
	done
}

vdr-plugin_copy_source_tree() {
	pushd . >/dev/null
	cp -r ${S} ${T}/source-tree
	cd ${T}/source-tree
	mv Makefile.orig Makefile
	sed -i Makefile \
		-e "s:^DVBDIR.*$:DVBDIR = ${DVB_INCLUDE_DIR}:" \
		-e 's:^CXXFLAGS:#CXXFLAGS:' \
		-e 's:-I$(DVBDIR)/include:-I$(DVBDIR):' \
		-e 's:-I$(VDRDIR) -I$(DVBDIR):-I$(DVBDIR) -I$(VDRDIR):'
	popd >/dev/null
}

vdr-plugin_install_source_tree() {
	einfo "Installing sources"
	destdir=${VDRSOURCE_DIR}/vdr-${VDRVERSION}/PLUGINS/src/${VDRPLUGIN}
	insinto ${destdir}-${PV}
	doins -r ${T}/source-tree/*

	dosym ${VDRPLUGIN}-${PV} ${destdir}
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
			cd ${S}

			emake ${BUILD_PARAMS} ${VDRPLUGIN_MAKE_TARGET:-all} || die "emake failed"
			;;
		esac

		shift
	done
}

vdr-plugin_src_install() {
	[[ -n "${VDRSOURCE_DIR}" ]] && vdr-plugin_install_source_tree
	cd ${S}

	if [[ -n ${VDR_MAINTAINER_MODE} ]]; then
		local mname=${P}-Makefile
		cp Makefile ${mname}.patched
		cp Makefile.orig ${mname}.before

		diff -u ${mname}.before ${mname}.patched > ${mname}.diff

		insinto "/usr/share/vdr/maintainer-data/makefile-changes"
		doins ${mname}.diff

		insinto "/usr/share/vdr/maintainer-data/makefile-before"
		doins ${mname}.before

		insinto "/usr/share/vdr/maintainer-data/makefile-patched"
		doins ${mname}.patched

	fi

	insinto "${VDR_PLUGIN_DIR}"
	doins libvdr-*.so.*
	local docfile
	for docfile in README* HISTORY CHANGELOG; do
		[[ -f ${docfile} ]] && dodoc ${docfile}
	done

	# if VDR_CONFD_FILE is empty and ${FILESDIR}/confd exists take it
	[[ -z ${VDR_CONFD_FILE} ]] && [[ -e ${FILESDIR}/confd ]] && VDR_CONFD_FILE=${FILESDIR}/confd

	if [[ -n ${VDR_CONFD_FILE} ]]; then
		insinto /etc/conf.d
		newins "${VDR_CONFD_FILE}" vdr.${VDRPLUGIN}
	fi


	# if VDR_RCADDON_FILE is empty and ${FILESDIR}/rc-addon.sh exists take it
	[[ -z ${VDR_RCADDON_FILE} ]] && [[ -e ${FILESDIR}/rc-addon.sh ]] && VDR_RCADDON_FILE=${FILESDIR}/rc-addon.sh

	if [[ -n ${VDR_RCADDON_FILE} ]]; then
		insinto "${VDR_RC_DIR}"
		newins "${VDR_RCADDON_FILE}" plugin-${VDRPLUGIN}.sh
	fi



	# Danger: Not using $ROOT here, as compile will also not use it !!!
	# If vdr in $ROOT and / differ, plugins will not run anyway

	insinto ${VDR_CHECKSUM_DIR}
	if [[ -f ${EPREFIX}${VDR_CHECKSUM_DIR}/header-md5-vdr ]]; then
		newins ${VDR_CHECKSUM_DIR}/header-md5-vdr header-md5-${PN}
	else
		if type -p md5sum >/dev/null 2>&1; then
			cd ${S}
			(
				cd ${EPREFIX}${VDR_INCLUDE_DIR}
				md5sum *.h libsi/*.h|LC_ALL=C sort --key=2
			) > header-md5-${PN}
			doins header-md5-${PN}
		fi
	fi

	create_plugindb_file
}

vdr-plugin_pkg_postinst() {
	if has_version "<=media-tv/vdrplugin-rebuild-0.1"; then
		update_vdrplugindb
	fi
	elog
	elog "The vdr plugin ${VDRPLUGIN} has now been installed."
	elog "To activate execute the following command:"
	elog
	elog "  emerge --config ${PN}"
	elog
	if [[ -n "${VDR_CONFD_FILE}" ]]; then
		elog "And have a look at the config-file"
		elog "/etc/conf.d/vdr.${VDRPLUGIN}"
		elog
	fi
}

vdr-plugin_pkg_postrm() {
	if has_version "<=media-tv/vdrplugin-rebuild-0.1"; then
		remove_vdrplugindb
	fi
	delete_orphan_plugindb_file
}

vdr-plugin_pkg_config_final() {
	diff ${conf_orig} ${conf}
	rm ${conf_orig}
}

vdr-plugin_pkg_config_old() {
	elog "Using interface of gentoo-vdr-scripts-0.3.6 and older"
	if [[ -z "${INSTALLPLUGIN}" ]]; then
		INSTALLPLUGIN="${VDRPLUGIN}"
	fi
	# First test if plugin is already inside PLUGINS
	local conf=/etc/conf.d/vdr
	conf_orig=${conf}.before_emerge_config
	cp ${conf} ${conf_orig}

	elog "Reading ${conf}"
	if ! grep -q "^PLUGINS=" ${conf}; then
		local LINE=$(sed ${conf} -n -e '/^#.*PLUGINS=/=' | tail -n 1)
		if [[ -n "${LINE}" ]]; then
			sed -e ${LINE}'a PLUGINS=""' -i ${conf}
		else
			echo 'PLUGINS=""' >> ${conf}
		fi
		unset LINE
	fi

	unset PLUGINS
	PLUGINS=$(source /etc/conf.d/vdr; echo ${PLUGINS})

	active=0
	for p in ${PLUGINS}; do
		if [[ "${p}" == "${INSTALLPLUGIN}" ]]; then
			active=1
			break;
		fi
	done

	if [[ "${active}" == "1" ]]; then
		elog "${INSTALLPLUGIN} already activated"
		echo
		read -p "Do you want to deactivate ${INSTALLPLUGIN} (yes/no) " answer
		if [[ "${answer}" != "yes" ]]; then
			elog "aborted"
			return
		fi
		elog "Removing ${INSTALLPLUGIN} from active plugins."
		local LINE=$(sed ${conf} -n -e '/^PLUGINS=.*\<'${INSTALLPLUGIN}'\>/=' | tail -n 1)
		sed -i ${conf} -e ${LINE}'s/\<'${INSTALLPLUGIN}'\>//' \
			-e ${LINE}'s/ \( \)*/ /g' \
			-e ${LINE}'s/ "/"/g' \
			-e ${LINE}'s/" /"/g'

		vdr-plugin_pkg_config_final
		return
	fi


	elog "Adding ${INSTALLPLUGIN} to active plugins."
	local LINE=$(sed ${conf} -n -e '/^PLUGINS=/=' | tail -n 1)
	sed -i ${conf} -e ${LINE}'s/^PLUGINS=" *\(.*\)"/PLUGINS="\1 '${INSTALLPLUGIN}'"/' \
		-e ${LINE}'s/ \( \)*/ /g' \
		-e ${LINE}'s/ "/"/g' \
		-e ${LINE}'s/" /"/g'

	vdr-plugin_pkg_config_final
}

vdr-plugin_pkg_config_new() {
	elog "Using interface introduced with gentoo-vdr-scripts-0.3.7"
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
	if has_version ">media-tv/gentoo-vdr-scripts-0.3.6"; then
		vdr-plugin_pkg_config_new
	else
		vdr-plugin_pkg_config_old
	fi
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
