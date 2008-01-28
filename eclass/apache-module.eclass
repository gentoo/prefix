# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/apache-module.eclass,v 1.21 2008/01/27 20:09:17 hollow Exp $

# @ECLASS: apache-module
# @MAINTAINER: apache-devs@gentoo.org
# @BLURB: Provides a common set of functions for apache modules
# @DESCRIPTION:
# This eclass handles apache modules in a sane way and providing information
# about where certain interfaces are located.
#
# @NOTE: If you use this, be sure you use the need_* call after you have defined
# DEPEND and RDEPEND. Also note that you can not rely on the automatic
# RDEPEND=DEPEND that Portage does if you use this eclass.
#
# See bug 107127 for more information.

inherit depend.apache

# ==============================================================================
# INTERNAL VARIABLES
# ==============================================================================

# @ECLASS-VARIABLE: APXS2_S
# @DESCRIPTION:
# Path to temporary build directory
APXS2_S=""

# @ECLASS-VARIABLE: APXS2_ARGS
# @DESCRIPTION:
# Arguments to pass to the apxs tool
APXS2_ARGS=""

# @ECLASS-VARIABLE: APACHE2_MOD_FILE
# @DESCRIPTION:
# Name of the module that src_install installs (minus the .so)
APACHE2_MOD_FILE=""

# @ECLASS-VARIABLE: APACHE2_MOD_CONF
# @DESCRIPTION:
# Configuration file installed by src_install
APACHE2_MOD_CONF=""

# @ECLASS-VARIABLE: APACHE2_VHOSTFILE
# @DESCRIPTION:
# Virtual host configuration file installed by src_install
APACHE2_VHOSTFILE=""

# @ECLASS-VARIABLE: APACHE2_MOD_DEFINE
# @DESCRIPTION:
# Name of define (eg FOO) to use in conditional loading of the installed
# module/it's config file, multiple defines should be space separated
APACHE2_MOD_DEFINE=""

# @ECLASS-VARIABLE: DOCFILES
# @DESCRIPTION:
# If the exported src_install() is being used, and ${DOCFILES} is non-zero, some
# sed-fu is applied to split out html documentation (if any) from normal
# documentation, and dodoc'd or dohtml'd
DOCFILES=""

# ==============================================================================
# PUBLIC FUNCTIONS
# ==============================================================================

# @FUNCTION: apache_cd_dir
# @DESCRIPTION:
# Return the path to our temporary build dir
apache_cd_dir() {
	debug-print-function $FUNCNAME $*

	[[ -n "${APXS2_S}" ]] && CD_DIR="${APXS2_S}"

	if [[ -z "${CD_DIR}" ]] ; then
		if [[ -d "${S}/src" ]] ; then
			CD_DIR="${S}/src"
		else
			CD_DIR="${S}"
		fi
	fi

	debug-print apache_cd_dir: "CD_DIR=${CD_DIR}"
	echo "${CD_DIR}"
}

# @FUNCTION: apache_mod_file
# @DESCRIPTION:
# Return the path to the module file
apache_mod_file() {
	debug-print-function $FUNCNAME $*

	[[ -n "${APACHE2_MOD_FILE}" ]] && MOD_FILE="${APACHE2_MOD_FILE}"
	[[ -z "${MOD_FILE}" ]] && MOD_FILE="$(apache_cd_dir)/.libs/${PN}.so"

	debug-print apache_mod_file: "MOD_FILE=${MOD_FILE}"
	echo "${MOD_FILE}"
}

# @FUNCTION: apache_doc_magic
# @DESCRIPTION:
# Some magic for picking out html files from ${DOCFILES}. It takes an optional
# first argument `html'; if the first argument is equals `html', only html files
# are returned, otherwise normal (non-html) docs are returned.
apache_doc_magic() {
	debug-print-function $FUNCNAME $*

	if [[ -n "${DOCFILES}" ]] ; then
		if [[ "x$1" == "xhtml" ]] ; then
			DOCS="`echo ${DOCFILES} | sed -e 's/ /\n/g' | sed -e '/^[^ ]*.html$/ !d'`"
		else
			DOCS="`echo ${DOCFILES} | sed 's, *[^ ]*\+.html, ,g'`"
		fi

		debug-print apache_doc_magic: "DOCS=${DOCS}"
		echo "${DOCS}"
	fi
}

# @FUNCTION: apache-module_pkg_setup
# @DESCRIPTION:
# Checks to see if APACHE2_SAFE_MPMS is set and if the currently installed MPM
# does appear in the list.
apache-module_pkg_setup() {
	debug-print-function $FUNCNAME $*

	if [[ -n "${APACHE2_SAFE_MPMS}" ]] ; then
		INSTALLED_MPM="$(${EROOT}/usr/sbin/apxs2 -q MPM_NAME)"

		if hasq ${INSTALLED_MPM} ${APACHE2_SAFE_MPMS} ; then
			INSTALLED_MPM_SAFE="yes"
		fi

		if [[ -z "${INSTALLED_MPM_SAFE}" ]] ; then
			eerror "The module you are trying to install (${PN})"
			eerror "will only work with one of the following MPMs:"
			eerror "    ${APACHE2_SAFE_MPMS}"
			eerror "You do not currently have any of these MPMs installed."
			eerror "Please re-install apache with the correct mpm-* USE flag set."
			die "No safe MPM installed."
		fi

	fi

}

# @FUNCTION: apache-module_src_compile
# @DESCRIPTION:
# The default action is to call ${APXS2} with the value of ${APXS2_ARGS}. If a
# module requires a different build setup than this, use ${APXS2} in your own
# src_compile routine.
apache-module_src_compile() {
	debug-print-function $FUNCNAME $*

	CD_DIR=$(apache_cd_dir)
	cd "${CD_DIR}" || die "cd ${CD_DIR} failed"
	APXS2_ARGS="${APXS2_ARGS:--c ${PN}.c}"
	${APXS2} ${APXS2_ARGS} || die "${APXS2} ${APXS2_ARGS} failed"
}

# @FUNCTION: apache-module_src_install
# @DESCRIPTION:
# This installs the files into apache's directories. The module is installed
# from a directory chosen as above (APXS2_S or ${S}/src). In addition, this
# function can also set the executable permission on files listed in
# APACHE2_EXECFILES.  The configuration file name is listed in APACHE2_MOD_CONF
# without the .conf extensions, so if you configuration is 55_mod_foo.conf,
# APACHE2_MOD_CONF would be 55_mod_foo.  DOCFILES contains the list of files you
# want filed as documentation.
apache-module_src_install() {
	debug-print-function $FUNCNAME $*

	CD_DIR=$(apache_cd_dir)
	cd "${CD_DIR}" || die "cd ${CD_DIR} failed"

	MOD_FILE=$(apache_mod_file)

	exeinto "${APACHE2_MODULESDIR}"
	doexe ${MOD_FILE} || die "internal ebuild error: '${MOD_FILE}' not found"
	[[ -n "${APACHE2_EXECFILES}" ]] && doexe ${APACHE2_EXECFILES}

	if [[ -n "${APACHE2_MOD_CONF}" ]] ; then
		insinto "${APACHE2_MODULES_CONFDIR}"
		set -- ${APACHE2_MOD_CONF}
		newins "${FILESDIR}/${1}.conf" "$(basename ${2:-$1}).conf" \
			|| die "internal ebuild error: '${FILESDIR}/${1}.conf' not found"
	fi

	if [[ -n "${APACHE2_VHOSTFILE}" ]] ; then
		insinto "${APACHE2_VHOSTDIR}"
		set -- ${APACHE2_VHOSTFILE}
		newins "${FILESDIR}/${1}.conf" "$(basename ${2:-$1}).conf " \
			|| die "internal ebuild error: '${FILESDIR}/${1}.conf' not found"
	fi

	cd "${S}"

	if [[ -n "${DOCFILES}" ]] ; then
		OTHER_DOCS=$(apache_doc_magic)
		HTML_DOCS=$(apache_doc_magic html)

		[[ -n "${OTHER_DOCS}" ]] && dodoc ${OTHER_DOCS}
		[[ -n "${HTML_DOCS}" ]] && dohtml ${HTML_DOCS}
	fi
}

# @FUNCTION: apache-module_pkg_postinst
# @DESCRIPTION:
# This prints out information about the installed module and how to enable it.
apache-module_pkg_postinst() {
	debug-print-function $FUNCNAME $*

	if [[ -n "${APACHE2_MOD_DEFINE}" ]] ; then
		local my_opts="-D ${APACHE2_MOD_DEFINE// / -D }"

		einfo
		einfo "To enable ${PN}, you need to edit your /etc/conf.d/apache2 file and"
		einfo "add '${my_opts}' to APACHE2_OPTS."
		einfo
	fi

	if [[ -n "${APACHE2_MOD_CONF}" ]] ; then
		set -- ${APACHE2_MOD_CONF}
		einfo
		einfo "Configuration file installed as"
		einfo "    ${APACHE2_MODULES_CONFDIR}/$(basename $1).conf"
		einfo "You may want to edit it before turning the module on in /etc/conf.d/apache2"
		einfo
	fi

	if [[ -n "${APACHE2_SAFE_MPMS}" ]] ; then
		INSTALLED_MPM="$(${EROOT}/usr/sbin/apxs2 -q MPM_NAME)"

		if ! hasq ${INSTALLED_MPM} ${APACHE2_SAFE_MPMS} ; then
			INSTALLED_MPM_UNSAFE="${INSTALLED_MPM_UNSAFE} ${mpm}"
		else
			INSTALLED_MPM_SAFE="${INSTALLED_MPM_SAFE} ${mpm}"
		fi

		if [[ -n "${INSTALLED_MPM_UNSAFE}" ]] ; then
			ewarn "Your installed MPM will not work with this module (${PN})."
			ewarn "Please make sure that you only enable this module"
			ewarn "if you are using one of the following MPMs:"
			ewarn "    ${INSTALLED_MPM_SAFE}"
		fi
	fi
}

EXPORT_FUNCTIONS pkg_setup src_compile src_install pkg_postinst
