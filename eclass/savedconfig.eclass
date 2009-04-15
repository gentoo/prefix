# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/savedconfig.eclass,v 1.10 2009/04/11 15:19:50 vapier Exp $

# @ECLASS: savedconfig.eclass
# @MAINTAINER:
# base-system@gentoo.org
# @BLURB: common API for saving/restoring complex configuration files
# @DESCRIPTION:
# It is not uncommon to come across a package which has a very fine
# grained level of configuration options that go way beyond what
# USE flags can properly describe.  For this purpose, a common API
# of saving and restoring the configuration files was developed
# so users can modify these config files and the ebuild will take it
# into account as needed.

inherit portability

IUSE="savedconfig"

# @FUNCTION: save_config
# @USAGE: <config files to save>
# @DESCRIPTION:
# Use this function to save the package's configuration file into the
# right location.  You may specify any number of configuration files,
# but just make sure you call save_config with all of them at the same
# time in order for things to work properly.
save_config() {
	if [[ ${EBUILD_PHASE} != "install" ]]; then
		die "Bad package!  save_config only for use in src_install functions!"
	fi
	case $# in
		0) die "Tell me what to save"
		    ;;
		1) if [[ -f "$1" ]]; then
				dodir /etc/portage/savedconfig/${CATEGORY}
				cp "$1" "${ED}"/etc/portage/savedconfig/${CATEGORY}/${PF} \
					|| die "Failed to save $1"
			else
				dodir /etc/portage/savedconfig/${CATEGORY}/${PF}
				treecopy "$1" "${ED}"/etc/portage/savedconfig/${CATEGORY}/${PF} \
					|| die "Failed to save $1"
			fi
			;;
		*)
			dodir "${PORTAGE_CONFIGROOT}"/etc/portage/savedconfig/${CATEGORY}/${PF}
			treecopy $* "${ED}/${PORTAGE_CONFIGROOT}"/etc/portage/savedconfig/${CATEGORY}/${PF} \
					|| die "Failed to save $1"
	esac
	elog "Your configuration for ${CATEGORY}/${PF} has been saved in "
	elog "/etc/portage/savedconfig/${CATEGORY}/${PF} for your editing pleasure."
	elog "You can edit these files by hand and remerge this package with"
	elog "USE=savedconfig to customise the configuration."
	elog "You can rename this file/directory to one of the following for"
	elog "its configuration to apply to multiple versions:"
	elog '${PORTAGE_CONFIGROOT}/etc/portage/savedconfig/'
	elog '[${CTARGET}|${CHOST}|""]/${CATEGORY}/[${PF}|${P}|${PN}]'
}

# @FUNCTION: restore_config
# @USAGE: <config files to restore>
# @DESCRIPTION:
# Restores the configuation saved ebuild previously potentially with user edits.
# You can restore a single file or a whole bunch, just make sure you call
# restore_config with all of the files to restore at the same time.
#
# Config files can be laid out as:
# @CODE
# ${PORTAGE_CONFIGROOT}/etc/portage/savedconfig/${CTARGET}/${CATEGORY}/${PF}
# ${PORTAGE_CONFIGROOT}/etc/portage/savedconfig/${CHOST}/${CATEGORY}/${PF}
# ${PORTAGE_CONFIGROOT}/etc/portage/savedconfig/${CATEGORY}/${PF}
# ${PORTAGE_CONFIGROOT}/etc/portage/savedconfig/${CTARGET}/${CATEGORY}/${P}
# ${PORTAGE_CONFIGROOT}/etc/portage/savedconfig/${CHOST}/${CATEGORY}/${P}
# ${PORTAGE_CONFIGROOT}/etc/portage/savedconfig/${CATEGORY}/${P}
# ${PORTAGE_CONFIGROOT}/etc/portage/savedconfig/${CTARGET}/${CATEGORY}/${PN}
# ${PORTAGE_CONFIGROOT}/etc/portage/savedconfig/${CHOST}/${CATEGORY}/${PN}
# ${PORTAGE_CONFIGROOT}/etc/portage/savedconfig/${CATEGORY}/${PN}
# @CODE
restore_config() {
	use savedconfig || return

	case ${EBUILD_PHASE} in
		unpack|compile|prepare)
		;;
		*) die "Bad package!  restore_config only for use in src_{unpack,compile,prepare} functions!"
		;;
	esac
	local found;
	local base=${PORTAGE_CONFIGROOT}/etc/portage/savedconfig
	for check in {${CATEGORY}/${PF},${CATEGORY}/${P},${CATEGORY}/${PN}}; do
		configfile=${base}/${CTARGET}/${check}
		[[ -r ${configfile} ]] || configfile=${base}/${CHOST}/${check}
		[[ -r ${configfile} ]] || configfile=${base}/${check}
		einfo "Checking existence of ${configfile} ..."
		if [[ -r "${configfile}" ]]; then
			einfo "found ${configfile}"
			found=${configfile};
			break;
		fi
	done
	if [[ -f ${found} ]]; then
		elog "Building using saved configfile ${found}"
		if [ $# -gt 0 ]; then
			cp -pPR	"${found}" "$1" || die "Failed to restore ${found} to $1"
		else
			die "need to know the restoration filename"
		fi
	elif [[ -d ${found} ]]; then
		elog "Building using saved config directory ${found}"
		dest=${PWD}
		pushd "${found}" > /dev/null
		treecopy . "${dest}" || die "Failed to restore ${found} to $1"
		popd > /dev/null
	elif [[ -a {found} ]]; then
		die "do not know how to handle non-file/directory ${found}"
	else
		eerror "No saved config to restore - please remove USE=savedconfig or"
		eerror "provide a configuration file in ${PORTAGE_CONFIGROOT}/etc/portage/savedconfig/${CATEGORY}/${PN}"
		die "config file needed when USE=savedconfig is specified"
	fi
}
