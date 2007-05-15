# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/apache-module.eclass,v 1.19 2007/05/12 02:28:51 chtekk Exp $

inherit depend.apache

# This eclass provides a common set of functions for Apache modules.

# NOTE: If you use this, be sure you use the need_* call after you have
# defined DEPEND and RDEPEND. Also note that you can not rely on the
# automatic RDEPEND=DEPEND that Portage does if you use this eclass.
# See bug 107127 for more information.

######
## Common ebuild variables
######

####
## APXS1_S, APXS2_S
##
## Paths to temporary build directories
####
APXS1_S=""
APXS2_S=""

####
## APXS1_ARGS, APXS2_ARGS
##
## Arguments to pass to the apxs tool
####
APXS1_ARGS=""
APXS2_ARGS=""

####
## APACHE1_MOD_FILE, APACHE2_MOD_FILE
##
## Name of the module that src_install installs (only, minus the .so)
####
APACHE1_MOD_FILE=""
APACHE2_MOD_FILE=""

####
## APACHE1_MOD_CONF, APACHE2_MOD_CONF
##
## Configuration file installed by src_install
####
APACHE1_MOD_CONF=""
APACHE2_MOD_CONF=""

####
## APACHE1_MOD_DEFINE, APACHE2_MOD_DEFINE
##
## Name of define (eg FOO) to use in conditional loading of the installed
## module/it's config file, multiple defines should be space separated
####
APACHE1_MOD_DEFINE=""
APACHE2_MOD_DEFINE=""

####
## DOCFILES
##
## If the exported src_install() is being used, and ${DOCFILES} is non-zero,
## some sed-fu is applied to split out html documentation (if any) from normal
## documentation, and dodoc'd or dohtml'd
####
DOCFILES=""

######
## Utility functions
######

####
## apache_cd_dir
##
## Return the path to our temporary build dir
####
apache_cd_dir() {
	debug-print-function $FUNCNAME $*

	if [[ "${APACHE_VERSION}" == "1" ]] ; then
		[[ -n "${APXS1_S}" ]] && CD_DIR="${APXS1_S}"
	else
		[[ -n "${APXS2_S}" ]] && CD_DIR="${APXS2_S}"
	fi

	# XXX - Is this really needed? Can't we just return ${S}?
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

####
## apache_mod_file
##
## Return the path to the module file
####
apache_mod_file() {
	debug-print-function $FUNCNAME $*

	if [[ "${APACHE_VERSION}" == "1" ]] ; then
		[[ -n "${APACHE1_MOD_FILE}" ]] && MOD_FILE="${APACHE1_MOD_FILE}"
		[[ -z "${MOD_FILE}" ]] && MOD_FILE="$(apache_cd_dir)/${PN}.so"
	else
		[[ -n "${APACHE2_MOD_FILE}" ]] && MOD_FILE="${APACHE2_MOD_FILE}"
		[[ -z "${MOD_FILE}" ]] && MOD_FILE="$(apache_cd_dir)/.libs/${PN}.so"
	fi

	debug-print apache_mod_file: "MOD_FILE=${MOD_FILE}"
	echo "${MOD_FILE}"
}

####
## apache_doc_magic
##
## Some magic for picking out html files from ${DOCFILES}. It takes
## an optional first argument `html'; if the first argument is equals
## `html', only html files are returned, otherwise normal (non-html)
## docs are returned.
####
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

######
## Apache 1.x ebuild functions - !!! DEPRECATED !!!
######

####
## apache1_src_compile - !!! DEPRECATED !!!
####
apache1_src_compile() {
	debug-print-function $FUNCNAME $*

	CD_DIR=$(apache_cd_dir)
	cd ${CD_DIR} || die "cd ${CD_DIR} failed"
	APXS1_ARGS="${APXS1_ARGS:--c ${PN}.c}"
	${APXS1} ${APXS1_ARGS} || die "${APXS1} ${APXS1_ARGS} failed"
}

####
## apache1_src_install - !!! DEPRECATED !!!
####
apache1_src_install() {
	debug-print-function $FUNCNAME $*

	CD_DIR=$(apache_cd_dir)
	cd ${CD_DIR} || die "cd ${CD_DIR} failed"

	MOD_FILE=$(apache_mod_file)

	exeinto ${APACHE1_MODULESDIR}
	doexe ${MOD_FILE} || die "internal ebuild error: '${MOD_FILE}' not found"
	[ -n "${APACHE1_EXECFILES}" ] && doexe ${APACHE1_EXECFILES}

	if [ -n "${APACHE1_MOD_CONF}" ] ; then
		insinto ${APACHE1_MODULES_CONFDIR}
		doins ${FILESDIR}/${APACHE1_MOD_CONF}.conf || die "internal ebuild error: '${FILESDIR}/${APACHE1_MOD_CONF}.conf' not found."
	fi

	cd ${S}

	if [ -n "${DOCFILES}" ] ; then
		OTHER_DOCS=$(apache_doc_magic)
		HTML_DOCS=$(apache_doc_magic html)

		[ -n "${OTHER_DOCS}" ] && dodoc ${OTHER_DOCS}
		[ -n "${HTML_DOCS}" ] && dohtml ${HTML_DOCS}
	fi
}

####
## apache1_pkg_postinst - !!! DEPRECATED !!!
####
apache1_pkg_postinst() {
	debug-print-function $FUNCNAME $*

	if [ -n "${APACHE1_MOD_DEFINE}" ]; then
		local my_opts="-D ${APACHE1_MOD_DEFINE// / -D }"

		einfo
		einfo "To enable ${PN}, you need to edit your /etc/conf.d/apache file and"
		einfo "add '${my_opts}' to APACHE_OPTS."
		einfo
	fi
	if [ -n "${APACHE1_MOD_CONF}" ] ; then
		einfo
		einfo "Configuration file installed as"
		einfo "  ${APACHE1_MODULES_CONFDIR}/$(basename ${APACHE1_MOD_CONF}).conf"
		einfo "You may want to edit it before turning the module on in /etc/conf.d/apache"
		einfo
	fi
}

######
## Apache 2.x ebuild functions
######

####
## apache2_pkg_setup
##
## Checks to see if APACHE2_MT_UNSAFE is set to anything other than "no". If it is, then
## we check what the MPM style used by Apache is, if it isnt prefork, we let the user
## know they need prefork, and then exit the build.
####
apache2_pkg_setup() {
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

####
## apache2_src_compile
##
## The default action is to call ${APXS2} with the value of
## ${APXS2_ARGS}. If a module requires a different build setup
## than this, use ${APXS2} in your own src_compile routine.
####
apache2_src_compile() {
	debug-print-function $FUNCNAME $*

	CD_DIR=$(apache_cd_dir)
	cd "${CD_DIR}" || die "cd ${CD_DIR} failed"
	APXS2_ARGS="${APXS2_ARGS:--c ${PN}.c}"
	${APXS2} ${APXS2_ARGS} || die "${APXS2} ${APXS2_ARGS} failed"
}

####
## apache2_src_install
##
## This installs the files into apache's directories. The module is installed
## from a directory chosen as above (APXS2_S or ${S}/src). In addition,
## this function can also set the executable permission on files listed in EXECFILES.
## The configuration file name is listed in CONFFILE without the .conf extensions,
## so if you configuration is 55_mod_foo.conf, CONFFILE would be 55_mod_foo.
## DOCFILES contains the list of files you want filed as documentation.
####
apache2_src_install() {
	debug-print-function $FUNCNAME $*

	CD_DIR=$(apache_cd_dir)
	cd "${CD_DIR}" || die "cd ${CD_DIR} failed"

	MOD_FILE=$(apache_mod_file)

	exeinto "${APACHE2_MODULESDIR}"
	doexe ${MOD_FILE} || die "internal ebuild error: '${MOD_FILE}' not found"
	[[ -n "${APACHE2_EXECFILES}" ]] && doexe ${APACHE2_EXECFILES}

	if [[ -n "${APACHE2_MOD_CONF}" ]] ; then
		insinto "${APACHE2_MODULES_CONFDIR}"
		doins "${FILESDIR}/${APACHE2_MOD_CONF}.conf" || die "internal ebuild error: '${FILESDIR}/${APACHE2_MOD_CONF}.conf' not found"
	fi

	if [[ -n "${APACHE2_VHOSTFILE}" ]] ; then
		insinto "${APACHE2_VHOSTDIR}"
		doins "${FILESDIR}/${APACHE2_VHOSTFILE}.conf" || die "internal ebuild error: '${FILESDIR}/${APACHE2_VHOSTFILE}.conf' not found"
	fi

	cd "${S}"

	if [[ -n "${DOCFILES}" ]] ; then
		OTHER_DOCS=$(apache_doc_magic)
		HTML_DOCS=$(apache_doc_magic html)

		[[ -n "${OTHER_DOCS}" ]] && dodoc ${OTHER_DOCS}
		[[ -n "${HTML_DOCS}" ]] && dohtml ${HTML_DOCS}
	fi
}

apache2_pkg_postinst() {
	debug-print-function $FUNCNAME $*

	if [[ -n "${APACHE2_MOD_DEFINE}" ]] ; then
		local my_opts="-D ${APACHE2_MOD_DEFINE// / -D }"

		einfo
		einfo "To enable ${PN}, you need to edit your /etc/conf.d/apache2 file and"
		einfo "add '${my_opts}' to APACHE2_OPTS."
		einfo
	fi

	if [[ -n "${APACHE2_MOD_CONF}" ]] ; then
		einfo
		einfo "Configuration file installed as"
		einfo "    ${APACHE2_MODULES_CONFDIR}/$(basename ${APACHE2_MOD_CONF}).conf"
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
			ewarn "You have one or more MPMs installed that will not work with"
			ewarn "this module (${PN}). Please make sure that you only enable"
			ewarn "this module if you are using one of the following MPMs:"
			ewarn "    ${INSTALLED_MPM_SAFE}"
		fi
	fi
}

######
## Apache dual (1.x or 2.x) ebuild functions - Apache 1.X DEPRECATED!
##
## This is where the magic happens. We provide dummy routines of all of the functions
## provided by all of the specifics. We use APACHE_ECLASS_VER_* to see which versions
## to call. If a function is provided by a given section (ie pkg_postinst in Apache 2.x)
## the exported routine simply does nothing.
######

apache-module_pkg_setup() {
	debug-print-function $FUNCNAME $*

	if [[ ${APACHE_VERSION} -eq "2" ]] ; then
		apache2_pkg_setup
	fi
}

apache-module_src_compile() {
	debug-print-function $FUNCNAME $*

	if [[ ${APACHE_VERSION} -eq "1" ]] ; then
		apache1_src_compile
	else
		apache2_src_compile
	fi
}

apache-module_src_install() {
	debug-print-function $FUNCNAME $*

	if [[ ${APACHE_VERSION} -eq "1" ]] ; then
		apache1_src_install
	else
		apache2_src_install
	fi
}

apache-module_pkg_postinst() {
	debug-print-function $FUNCNAME $*

	if [[ ${APACHE_VERSION} -eq "1" ]] ; then
		apache1_pkg_postinst
	else
		apache2_pkg_postinst
	fi
}

EXPORT_FUNCTIONS pkg_setup src_compile src_install pkg_postinst
