# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/webapp.eclass,v 1.47 2006/12/31 19:16:31 rl03 Exp $
#
# eclass/webapp.eclass
#				Eclass for installing applications to run under a web server
#
#				Part of the implementation of GLEP #11
#
# Author(s)		Stuart Herbert
#				Renat Lumpau <rl03@gentoo.org>
#				Gunnar Wrobel <wrobel@gentoo.org>
#
# ------------------------------------------------------------------------
#
# The master copy of this eclass is held in our subversion repository.
# http://svn.gnqs.org/projects/vhost-tools/browser/
#
# If you make changes to this file and don't tell us, chances are that
# your changes will be overwritten the next time we release a new version
# of webapp-config.
#
# ------------------------------------------------------------------------

SLOT="${PVR}"
IUSE="vhosts"
DEPEND=">=app-admin/webapp-config-1.50.15"
RDEPEND="${DEPEND}"

EXPORT_FUNCTIONS pkg_postinst pkg_setup src_install pkg_prerm

INSTALL_DIR="/${PN}"
IS_UPGRADE=0
IS_REPLACE=0

INSTALL_CHECK_FILE="installed_by_webapp_eclass"

ETC_CONFIG="${EROOT}/etc/vhosts/webapp-config"
WEBAPP_CONFIG="${EROOT}/usr/sbin/webapp-config"
WEBAPP_CLEANER="${EROOT}/usr/sbin/webapp-cleaner"

# ------------------------------------------------------------------------
# INTERNAL FUNCTION - USED BY THIS ECLASS ONLY
#
# Load the config file /etc/vhosts/webapp-config
#
# Supports both the old bash version, and the new python version
#
# ------------------------------------------------------------------------

function webapp_read_config ()
{
	if has_version '>=app-admin/webapp-config-1.50'; then
		ENVVAR=$(${WEBAPP_CONFIG} --query ${PN} ${PVR}) || die "Could not read settings from webapp-config!"
		eval ${ENVVAR}
	else
		. ${ETC_CONFIG} || die "Unable to read ${ETC_CONFIG}"
	fi
}

# ------------------------------------------------------------------------
# INTERNAL FUNCTION - USED BY THIS ECLASS ONLY
#
# Check whether a specified file exists within the image/ directory
# or not.
#
# @param 	$1 - file to look for
# @param	$2 - prefix directory to use
# @return	0 on success, never returns on an error
# ------------------------------------------------------------------------

function webapp_checkfileexists ()
{
	local my_prefix

	[ -n "${2}" ] && my_prefix="${2}/" || my_prefix=

	if [ ! -e "${my_prefix}${1}" ]; then
		msg="ebuild fault: file '${1}' not found"
		eerror "$msg"
		eerror "Please report this as a bug at http://bugs.gentoo.org/"
		die "$msg"
	fi
}

# ------------------------------------------------------------------------
# INTERNAL FUNCTION - USED BY THIS ECLASS ONLY
# ------------------------------------------------------------------------

function webapp_check_installedat
{
	local my_output

	${WEBAPP_CONFIG} --show-installed -h localhost -d "${INSTALL_DIR}" 2> /dev/null
}

# ------------------------------------------------------------------------
# INTERNAL FUNCTION - USED BY THIS ECLASS ONLY
#
# ------------------------------------------------------------------------

function webapp_strip_appdir ()
{
	local my_stripped="${1}"
	echo "${1}" | sed -e "s|${MY_APPDIR}/||g;"
}

function webapp_strip_d ()
{
	echo "${1}" | sed -e "s|${ED}||g;"
}

function webapp_strip_cwd ()
{
	local my_stripped="${1}"
	echo "${1}" | sed -e 's|/./|/|g;'
}

# ------------------------------------------------------------------------
# EXPORTED FUNCTION - FOR USE IN EBUILDS
#
# Identify a config file for a web-based application.
#
# @param	$1 - config file
# ------------------------------------------------------------------------

function webapp_configfile ()
{
	local m=""
	for m in "$@" ; do
		webapp_checkfileexists "${m}" "${ED}"

		local MY_FILE="$(webapp_strip_appdir "${m}")"
		MY_FILE="$(webapp_strip_cwd "${MY_FILE}")"

		elog "(config) ${MY_FILE}"
		echo "${MY_FILE}" >> ${ED}/${WA_CONFIGLIST}
	done
}

# ------------------------------------------------------------------------
# EXPORTED FUNCTION - FOR USE IN EBUILDS
#
# Install a script that will run after a virtual copy is created, and
# before a virtual copy has been removed
#
# @param	$1 - the script to run
# ------------------------------------------------------------------------

function webapp_hook_script ()
{
	webapp_checkfileexists "${1}"

	elog "(hook) ${1}"
	cp "${1}" "${ED}/${MY_HOOKSCRIPTSDIR}/$(basename "${1}")" || die "Unable to install ${1} into ${ED}/${MY_HOOKSCRIPTSDIR}/"
	chmod 555 "${ED}/${MY_HOOKSCRIPTSDIR}/$(basename "${1}")"
}

# ------------------------------------------------------------------------
# EXPORTED FUNCTION - FOR USE IN EBUILDS
#
# Install a text file containing post-installation instructions.
#
# @param	$1 - language code (use 'en' for now)
# @param	$2 - the file to install
# ------------------------------------------------------------------------

function webapp_postinst_txt ()
{
	webapp_checkfileexists "${2}"

	elog "(info) ${2} (lang: ${1})"
	cp "${2}" "${ED}/${MY_APPDIR}/postinst-${1}.txt"
}

# ------------------------------------------------------------------------
# EXPORTED FUNCTION - FOR USE IN EBUILDS
#
# Install a text file containing post-upgrade instructions.
#
# @param	$1 - language code (use 'en' for now)
# @param	$2 - the file to install
# ------------------------------------------------------------------------

function webapp_postupgrade_txt ()
{
	webapp_checkfileexists "${2}"

	elog "(info) ${2} (lang: ${1})"
	cp "${2}" "${ED}/${MY_APPDIR}/postupgrade-${1}.txt"
}

# ------------------------------------------------------------------------
# EXPORTED FUNCTION - FOR USE IN EBUILDS
#
# Identify a file which must be owned by the webserver's user:group
# settings.
#
# The ownership of the file is NOT set until the application is installed
# using the webapp-config tool.
#
# @param	$1 - file to be owned by the webserver user:group combo
#
# ------------------------------------------------------------------------

function webapp_serverowned ()
{
	local a=""
	local m=""
	if [ "${1}" = "-R" ]; then
		shift
		for m in "$@" ; do
			for a in $(find ${ED}/${m}); do
				a=${a/${ED}\/\///}
				webapp_checkfileexists "${a}" "$D"
				local MY_FILE="$(webapp_strip_appdir "${a}")"
				MY_FILE="$(webapp_strip_cwd "${MY_FILE}")"

				elog "(server owned) ${MY_FILE}"
				echo "${MY_FILE}" >> "${ED}/${WA_SOLIST}"
			done
		done
	else
		for m in "$@" ; do
			webapp_checkfileexists "${m}" "$D"
			local MY_FILE="$(webapp_strip_appdir "${m}")"
			MY_FILE="$(webapp_strip_cwd "${MY_FILE}")"

			elog "(server owned) ${MY_FILE}"
			echo "${MY_FILE}" >> "${ED}/${WA_SOLIST}"
		done
	fi
}

# ------------------------------------------------------------------------
# EXPORTED FUNCTION - FOR USE IN EBUILDS
#
# @param	$1 - the webserver to install the config file for
#			     (one of apache1, apache2, cherokee)
# @param	$2 - the config file to install
# @param	$3 - new name for the config file (default is `basename $2`)
#				 this is an optional parameter
#
# NOTE:
#	this function will automagically prepend $1 to the front of your
#	config file's name
# ------------------------------------------------------------------------

function webapp_server_configfile ()
{
	webapp_checkfileexists "${2}"

	# sort out what the name will be of the config file

	local my_file

	if [ -z "${3}" ]; then
		my_file="${1}-$(basename "${2}")"
	else
		my_file="${1}-${3}"
	fi

	# warning:
	#
	# do NOT change the naming convention used here without changing all
	# the other scripts that also rely upon these names

	elog "(${1}) config file '${my_file}'"
	cp "${2}" "${ED}/${MY_SERVERCONFIGDIR}/${my_file}"
}

# ------------------------------------------------------------------------
# EXPORTED FUNCTION - FOR USE IN EBUILDS
#
# @param	$1 - the db engine that the script is for
#				 (one of: mysql|postgres)
# @param	$2 - the sql script to be installed
# @param	$3 - the older version of the app that this db script
#				 will upgrade from
#				 (do not pass this option if your SQL script only creates
#				  a new db from scratch)
# ------------------------------------------------------------------------

function webapp_sqlscript ()
{
	webapp_checkfileexists "${2}"

	# create the directory where this script will go
	#
	# scripts for specific database engines go into their own subdirectory
	# just to keep things readable on the filesystem

	if [ ! -d "${ED}/${MY_SQLSCRIPTSDIR}/${1}" ]; then
		mkdir -p "${ED}/${MY_SQLSCRIPTSDIR}/${1}" || die "unable to create directory ${ED}/${MY_SQLSCRIPTSDIR}/${1}"
	fi

	# warning:
	#
	# do NOT change the naming convention used here without changing all
	# the other scripts that also rely upon these names

	# are we dealing with an 'upgrade'-type script?
	if [ -n "${3}" ]; then
		# yes we are
		elog "(${1}) upgrade script from ${PN}-${PVR} to ${3}"
		cp "${2}" "${ED}${MY_SQLSCRIPTSDIR}/${1}/${3}_to_${PVR}.sql"
		chmod 600 "${ED}${MY_SQLSCRIPTSDIR}/${1}/${3}_to_${PVR}.sql"
	else
		# no, we are not
		elog "(${1}) create script for ${PN}-${PVR}"
		cp "${2}" "${ED}/${MY_SQLSCRIPTSDIR}/${1}/${PVR}_create.sql"
		chmod 600 "${ED}/${MY_SQLSCRIPTSDIR}/${1}/${PVR}_create.sql"
	fi
}

# ------------------------------------------------------------------------
# EXPORTED FUNCTION - call from inside your ebuild's src_install AFTER
# everything else has run
#
# For now, we just make sure that root owns everything, and that there
# are no setuid files.
# ------------------------------------------------------------------------

function webapp_src_install ()
{
	chown -R "${VHOST_DEFAULT_UID}:${VHOST_DEFAULT_GID}" "${ED}/"
	chmod -R u-s "${ED}/"
	chmod -R g-s "${ED}/"

	keepdir "${MY_PERSISTDIR}"
	fowners "root:0" "${MY_PERSISTDIR}"
	fperms 755 "${MY_PERSISTDIR}"

	# to test whether or not the ebuild has correctly called this function
	# we add an empty file to the filesystem
	#
	# we used to just set a variable in the shell script, but we can
	# no longer rely on Portage calling both webapp_src_install() and
	# webapp_pkg_postinst() within the same shell process

	touch "${ED}/${MY_APPDIR}/${INSTALL_CHECK_FILE}"
}

# ------------------------------------------------------------------------
# EXPORTED FUNCTION - call from inside your ebuild's pkg_config AFTER
# everything else has run
#
# If 'vhosts' USE flag is not set, auto-install this app
#
# ------------------------------------------------------------------------

function webapp_pkg_setup ()
{
	# add sanity checks here

	# special case - some ebuilds *do* need to overwride the SLOT
	if [[ "${SLOT}+" != "${PVR}+" && "${WEBAPP_MANUAL_SLOT}" != "yes" ]]; then
		die "Set WEBAPP_MANUAL_SLOT=\"yes\" if you need to SLOT manually"
	fi

	# pull in the shared configuration file

	G_HOSTNAME="localhost"
	webapp_read_config

	# are we installing a webapp-config solution over the top of a
	# non-webapp-config solution?

	if ! use vhosts ; then
		local my_dir="${EROOT}${VHOST_ROOT}/${MY_HTDOCSBASE}/${PN}"
		local my_output

		if [ -d "${my_dir}" ] ; then
			my_output="$(webapp_check_installedat)"

			if [ "$?" != "0" ]; then
				# okay, whatever is there, it isn't webapp-config-compatible
				ewarn "You already have something installed in ${my_dir}"
				ewarn
				ewarn "Whatever is in ${my_dir}, it's not"
				ewarn "compatible with webapp-config."
				ewarn
				ewarn "This ebuild may be overwriting important files."
				ewarn
			elif [ "$(echo ${my_output} | awk '{ print $1 }')" != "${PN}" ]; then
				eerror "${my_dir} contains ${my_output}"
				eerror "I cannot upgrade that"
				die "Cannot upgrade contents of ${my_dir}"
			fi
		fi
	fi
}

function webapp_getinstalltype ()
{
	# or are we upgrading?

	if ! use vhosts ; then
		# we only run webapp-config if vhosts USE flag is not set

		local my_output

		my_output="$(webapp_check_installedat)"

		if [ "${?}" = "0" ] ; then
			# something is already installed there
			#
			# make sure it isn't the same version

			local my_pn="$(echo ${my_output} | awk '{ print $1 }')"
			local my_pvr="$(echo ${my_output} | awk '{ print $2 }')"

			REMOVE_PKG="${my_pn}-${my_pvr}"

			if [ "${my_pn}" == "${PN}" ]; then
				if [ "${my_pvr}" != "${PVR}" ]; then
					elog "This is an upgrade"
					IS_UPGRADE=1
				else
					elog "This is a re-installation"
					IS_REPLACE=1
				fi
			else
				elog "${my_output} is installed there"
			fi
		else
			elog "This is an installation"
		fi
	fi
}

function webapp_src_preinst ()
{
	# create the directories that we need

	dodir "${MY_HTDOCSDIR}"
	dodir "${MY_HOSTROOTDIR}"
	dodir "${MY_CGIBINDIR}"
	dodir "${MY_ICONSDIR}"
	dodir "${MY_ERRORSDIR}"
	dodir "${MY_SQLSCRIPTSDIR}"
	dodir "${MY_HOOKSCRIPTSDIR}"
	dodir "${MY_SERVERCONFIGDIR}"
}

function webapp_pkg_postinst ()
{
	webapp_read_config

	# sanity checks, to catch bugs in the ebuild

	if [ ! -f "${EROOT}${MY_APPDIR}/${INSTALL_CHECK_FILE}" ]; then
		eerror
		eerror "This ebuild did not call webapp_src_install() at the end"
		eerror "of the src_install() function"
		eerror
		eerror "Please log a bug on http://bugs.gentoo.org"
		eerror
		eerror "You should use emerge -C to remove this package, as the"
		eerror "installation is incomplete"
		eerror
		die "Ebuild did not call webapp_src_install() - report to http://bugs.gentoo.org"
	fi

	# if 'vhosts' is not set in your USE flags, we install a copy of
	# this application in ${EROOT}/var/www/localhost/htdocs/${PN}/ for you

	if ! use vhosts ; then
		echo
		elog "vhosts USE flag not set - auto-installing using webapp-config"

		webapp_getinstalltype

		G_HOSTNAME="localhost"
		local my_mode=-I
		webapp_read_config

		if [ "${IS_REPLACE}" = "1" ]; then
			elog "${PN}-${PVR} is already installed - replacing"
			my_mode=-I
		elif [ "${IS_UPGRADE}" = "1" ]; then
			elog "${REMOVE_PKG} is already installed - upgrading"
			my_mode=-U
		else
			elog "${PN}-${PVR} is not installed - using install mode"
		fi

		my_cmd="${WEBAPP_CONFIG} ${my_mode} -h localhost -u root -d ${INSTALL_DIR} ${PN} ${PVR}"
		elog "Running ${my_cmd}"
		${my_cmd}

		# run webapp-cleaner instead of emerge
		echo
		local cleaner="${WEBAPP_CLEANER} -p -C ${PN}"
		einfo "Running ${cleaner}"
		${cleaner}
	else
		# vhosts flag is on
		#
		# let's tell the administrator what to do next

		elog
		elog "The 'vhosts' USE flag is switched ON"
		elog "This means that Portage will not automatically run webapp-config to"
		elog "complete the installation."
		elog
		elog "To install ${PN}-${PVR} into a virtual host, run the following command:"
		elog
		elog "    webapp-config -I -h <host> -d ${PN} ${PN} ${PVR}"
		elog
		elog "For more details, see the webapp-config(8) man page"
	fi

	return 0
}

function webapp_pkg_prerm ()
{
	# remove any virtual installs that there are

	local my_output
	local x

	my_output="$(${WEBAPP_CONFIG} --list-installs ${PN} ${PVR})"

	if [ "${?}" != "0" ]; then
		return
	fi

	for x in ${my_output} ; do
		[ -f ${x}/.webapp ] && . ${x}/.webapp || ewarn "Cannot find file ${x}/.webapp"

		if [ -z "${WEB_HOSTNAME}" -o -z "${WEB_INSTALLDIR}" ]; then
			ewarn "Don't forget to use webapp-config to remove the copy of"
			ewarn "${PN}-${PVR} installed in"
			ewarn
			ewarn "    ${x}"
			ewarn
		else
			# we have enough information to remove the virtual copy ourself

			${WEBAPP_CONFIG} -C -h ${WEB_HOSTNAME} -d ${WEB_INSTALLDIR}

			# if the removal fails - we carry on anyway!
		fi
	done
}
