# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/depend.apache.eclass,v 1.28 2006/11/26 21:25:28 vericgar Exp $

inherit multilib

# This eclass handles depending on apache in a sane way and providing
# information about where certain interfaces are located.

# NOTE: If you use this, be sure you use the need_* call after you have
# defined DEPEND and RDEPEND. Also note that you can not rely on the
# automatic RDEPEND=DEPEND that portage does if you use this eclass.
# See bug 107127 for more information.

######
## Apache Common Variables
##
## These are internal variables used by this, and other apache-related eclasses,
## and thus should not need to be used by the ebuilds themselves (the ebuilds
## should know what version of Apache they are building against).
######

####
## APACHE_VERSION
##
## Stores the version of apache we are going to be ebuilding.  This variable is
## set by the need_apache{|1|2} functions.
##
####
#APACHE_VERSION='2'

####
## APXS1, APXS2
##
## Paths to the apxs tools
####
APXS1="/usr/sbin/apxs"
APXS2="/usr/sbin/apxs2"

####
## APACHECTL1, APACHECTL2
##
## Paths to the apachectl tools
####
APACHECTL1="/usr/sbin/apachectl"
APACHECTL2="/usr/sbin/apache2ctl"

####
## APACHE1_BASEDIR, APACHE2_BASEDIR
##
## Paths to the server root directories
####
APACHE1_BASEDIR="/usr/$(get_libdir)/apache"
APACHE2_BASEDIR="/usr/$(get_libdir)/apache2"

####
## APACHE1_CONFDIR, APACHE2_CONFDIR
##
## Paths to the configuration file directories (usually under
## $APACHE?_BASEDIR/conf)
####
APACHE1_CONFDIR="/etc/apache"
APACHE2_CONFDIR="/etc/apache2"

####
## APACHE1_MODULES_CONFDIR, APACHE2_MODULES_CONFDIR
##
## Paths where module configuration files are kept
####
APACHE1_MODULES_CONFDIR="${APACHE1_CONFDIR}/modules.d"
APACHE2_MODULES_CONFDIR="${APACHE2_CONFDIR}/modules.d"

####
## APACHE1_VHOSTDIR, APACHE2_VHOSTDIR
##
## Paths where virtual host configuration files are kept
####
APACHE1_VHOSTDIR="${APACHE1_CONFDIR}/vhosts.d"
APACHE2_VHOSTDIR="${APACHE2_CONFDIR}/vhosts.d"

####
## APACHE1_MODULESDIR, APACHE2_MODULESDIR
##
## Paths where we install modules
####
APACHE1_MODULESDIR="${APACHE1_BASEDIR}/modules"
APACHE2_MODULESDIR="${APACHE2_BASEDIR}/modules"

####
## APACHE1_DEPEND, APACHE2_DEPEND
## APACHE2_0_DEPEND, APACHE2_2_DEPEND
##
## Dependencies for apache 1.x and apache 2.x
####
APACHE1_DEPEND="=net-www/apache-1*"
APACHE2_DEPEND="=net-www/apache-2*"
APACHE2_0_DEPEND="=net-www/apache-2.0*"
APACHE2_2_DEPEND="=net-www/apache-2.2*"

####
## NEED_APACHE_DEPEND
##
## Dependency magic based on useflags to use the right DEPEND
## If you change this, please check the DEPENDS in need_apache() 
####

NEED_APACHE_DEPEND="apache2? ( ${APACHE2_DEPEND} ) !apache2? ( ${APACHE1_DEPEND} )"
WANT_APACHE_DEPEND="apache2? ( ${APACHE2_DEPEND} ) !apache2? ( apache? ( ${APACHE1_DEPEND} ) )"

####
# uses_apache1()
#
# sets up all of the environment variables required by an apache1 module
####

uses_apache1() {
	debug-print-function $FUNCNAME $*
	# WARNING: Do not use these variables with anything that is put
	# into the dependency cache (DEPEND/RDEPEND/etc)
	APACHE_VERSION='1'
	APXS="$APXS1"
	USE_APACHE2=
	APACHECTL="${APACHECTL1}"
	APACHE_BASEDIR="${APACHE1_BASEDIR}"
	APACHE_CONFDIR="${APACHE1_CONFDIR}"
	APACHE_MODULES_CONFDIR="${APACHE1_MODULES_CONFDIR}"
	APACHE_VHOSTSDIR="${APACHE1_VHOSTSDIR}"
	APACHE_MODULESDIR="${APACHE1_MODULESDIR}"
}

####
# uses_apache2()
#
# sets up all of the environment variables required by an apache2 module
####

uses_apache2() {
	debug-print-function $FUNCNAME $*
	# WARNING: Do not use these variables with anything that is put
	# into the dependency cache (DEPEND/RDEPEND/etc)
	APACHE_VERSION='2'
	USE_APACHE2=2
	APXS="$APXS2"
	APACHECTL="${APACHECTL2}"
	APACHE_BASEDIR="${APACHE2_BASEDIR}"
	APACHE_CONFDIR="${APACHE2_CONFDIR}"
	APACHE_MODULES_CONFDIR="${APACHE2_MODULES_CONFDIR}"
	APACHE_VHOSTSDIR="${APACHE2_VHOSTSDIR}"
	APACHE_MODULESDIR="${APACHE2_MODULESDIR}"
}

doesnt_use_apache() {
	debug-print-function $FUNCNAME $*
	APACHE_VERSION='0'
	USE_APACHE=
}

####
## need_apache1
##
## An ebuild calls this to get the dependency information
## for apache-1.x.  An ebuild should use this in order for
## future changes to the build infrastructure to happen
## seamlessly.  All an ebuild needs to do is include the
## line need_apache1 somewhere.
####
need_apache1() {
	debug-print-function $FUNCNAME $*

	DEPEND="${DEPEND} ${APACHE1_DEPEND}"
	RDEPEND="${RDEPEND} ${APACHE1_DEPEND}"
	APACHE_VERSION='1'
}

####
## need_apache2
##
## An ebuild calls this to get the dependency information
## for apache-2.x.  An ebuild should use this in order for
## future changes to the build infrastructure to happen
## seamlessly.  All an ebuild needs to do is include the
## line need_apache2 somewhere.
####
need_apache2() {
	debug-print-function $FUNCNAME $*

	DEPEND="${DEPEND} ${APACHE2_DEPEND}"
	RDEPEND="${RDEPEND} ${APACHE2_DEPEND}"
	APACHE_VERSION='2'
}

####
## need_apache2_0
##
## Works like need_apache2 above, but its used by modules
## that only support apache 2.0 and do not work with
## higher versions
##
####
need_apache2_0() {
	debug-print-function $FUNCNAME $*

	DEPEND="${DEPEND} ${APACHE2_0_DEPEND}"
	RDEPEND="${RDEPEND} ${APACHE2_0_DEPEND}"
	APACHE_VERSION='2'
}

####
## need_apache2_2
##
## Works like need_apache2 above, but its used by modules
## that only support apache 2.2.
##
####
need_apache2_2() {
	debug-print-function $FUNCNAME $*

	DEPEND="${DEPEND} ${APACHE2_2_DEPEND}"
	RDEPEND="${RDEPEND} ${APACHE2_2_DEPEND}"
	APACHE_VERSION='2'
}

####
## DO NOT CHANGE THIS FUNCTION UNLESS YOU UNDERSTAND THE CONSEQUENCES IT
## WILL HAVE ON THE CACHE! There MUST be a apache2? () block in DEPEND for
## things to work correct in the dependency calculation stage.
##
## This function can take a variable amount of arguments specifying the
## versions of apache the ebuild supports
##
## If no arguments are specified, then all versions are assumed to be supported
##
## If both 1.3 and 2.x are specified, the apache2 USE-flag will be used in
## DEPEND/RDEPEND to determine which version to use.
##
## Currently supported versions: 1.3 2.0 2.2 2.x
need_apache() {
	debug-print-function $FUNCNAME $*

	local supports13 supports20 supports22 supports2x

	if [ $# -eq 0 ]; then
		supports13=yes
		supports2x=yes
	else
		while [ $# -gt 0 ]; do
			case "$1" in
				1.3)	supports13=yes; shift;;
				2.0)	supports20=yes; shift;;
				2.2)	supports22=yes; shift;;
				2.x)	supports2x=yes; shift;;
				*)		die "Unknown version specifier: $1";;
			esac
		done
	fi

	if [[ "${supports20}" == "yes" && "${supports22}" == "yes" ]]; then
		supports2x=yes;
	fi
	
	debug-print "supports13: ${supports13}"
	debug-print "supports20: ${supports20}"
	debug-print "supports22: ${supports22}"
	debug-print "supports2x: ${supports2x}"
	
	if [ "${supports13}" != "yes" ]; then
		if [ "${supports2x}" == "yes" ]; then
			need_apache2
		elif [ "${supports20}" == "yes" ]; then
			need_apache2_0
		elif [ "${supports22}" == "yes" ]; then
			need_apache2_2
		fi
	elif [ "${supports13}" == "yes" ]; then
		if [[ 	"${supports2x}" == "yes" || 
				"${supports20}" == "yes" ||
				"${supports22}" == "yes" ]]; then

			# we support both apache-1.3 and apache-2.*, set up USE-flag based
			# DEPEND and RDEPEND, determined by which apache-2.x we support

			IUSE="${IUSE} apache2"

			if [ "${supports2x}" != "yes" ]; then
				if [ "${supports20}" == "yes" ]; then
					NEED_APACHE_DEPEND="apache2? ( ${APACHE2_0_DEPEND} ) !apache2? ( ${APACHE1_DEPEND} )"
				elif [ "${supports22}" == "yes" ]; then
					NEED_APACHE_DEPEND="apache2? ( ${APACHE2_2_DEPEND} ) !apache2? ( ${APACHE1_DEPEND} )"
				fi
			fi
			
			DEPEND="${DEPEND} ${NEED_APACHE_DEPEND}"
			RDEPEND="${RDEPEND} ${NEED_APACHE_DEPEND}"
			
			if useq apache2; then
				uses_apache2
			else
				uses_apache1
			fi
		else
			need_apache1
		fi
	fi

}

want_apache() {
	debug-print-function $FUNCNAME $*

	IUSE="${IUSE} apache apache2"
	DEPEND="${DEPEND} ${WANT_APACHE_DEPEND}"
	RDEPEND="${RDEPEND} ${WANT_APACHE_DEPEND}"
	if useq apache2 ; then
		uses_apache2
	elif useq apache ; then
		uses_apache1
	else
		doesnt_use_apache
	fi
}
