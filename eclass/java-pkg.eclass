# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/java-pkg.eclass,v 1.47 2006/11/26 21:59:41 betelgeuse Exp $

inherit multilib

EXPORT_FUNCTIONS pkg_setup

# We need to do a few things to add compatibility between
# generation-1 and generation-2.

# First we make sure java-config-1 will be used
export WANT_JAVA_CONFIG="1"

# During pkg_setup, we need to do a few extra things to ensure things work in a
# mixed generation-1/generation-2 environment
# TODO need to make sure everything that inherits java-pkg and has a pkg_setup
# uses java-pkg_pkg_setup
java-pkg_pkg_setup() {
	java-pkg_announce-qa-violation "using deprecated eclass java-pkg"

	# We need to do a little magic if java-config-2 is around
	if has_version "=dev-java/java-config-2*"; then
		# we only want to enable the Java stuff if
		# there isn't a Java use flag (means its a pure Java pckage)
		# or if there is a Java use flag and it is enabled
		if ! hasq java ${IUSE} || use java; then
			initialize-java-environment
			if [[ -n ${GENTOO_VM} ]]; then
				einfo "Using Generation-1 System VM: ${GENTOO_VM}"
			else
				echo
				eerror "There was a problem determining which VM to use for generation-1"
				eerror "This is because the way Java is handled on Gentoo has drastically changed."
				if ! has_version "=virtual/jdk-1.4*" || ! has_version "=virtual/jdk-1.3*"; then
					ewarn "There does not seem to be a 1.4 or 1.3 JDK installed."
					ewarn "You should probably install =virtual/jdk-1.4* or =virtual/jdk-1.3*"
					ewarn "It is important to have either a 1.4 or 1.3 JDK installed"
					ewarn "in order for the old and new Java systems to coexist"
					ewarn "Details about this can be found at:"
					ewarn "\thttp://overlays.gentoo.org/proj/java/wiki/Why_We_Need_Java14"
					echo
				fi

				eerror "You should run, and follow the advice of:"
				eerror "\t/usr/bin/java-check-environment"

				eerror "You will also likely want to follow the Java Upgrade Guide:"
				eerror "\thttp://www.gentoo.org/proj/en/java/java-upgrade.xml"
				eerror "If you have problems with the guide, please see:"
				eerror "\thttp://overlays.gentoo.org/proj/java/wiki/Common_Problems"
				die "Expected VMHANDLE to be defined in the env"
			fi
		fi
	fi
}

initialize-java-environment() {
	if has_version "=dev-java/java-config-2*"; then
		# VMHANDLE is the variable in an env file that identifies how java-config-2
		# knows a VM. With each VM, we have a 'compatible' env file installed to
		# /etc/env.d/java, so java-config-1 can work.
		#
		# So, here we set GENTOO_VM to be VMHANDLE, and thus to the
		# generation-1 system VM.
		export GENTOO_VM=$(java-config-1 -g VMHANDLE)

		# use java-config-2, with GENTOO_VM set to generation-1 system vm, to
		# setup JAVA_HOME
		export JAVA_HOME=$(java-config-2 --jdk-home)
		export JDK_HOME=$(java-config-2 --jdk-home)
		# make sure JAVAC and JAVA are set correctly
		export JAVAC=$(java-config-2 --javac)
		export JAVA=$(java-config-2 --java)
	fi
	# Otherwise, JAVA_HOME should be defined already
}

# These are pre hooks to make sure JAVA_HOME is set properly.
# note: don't need pkg_setup, since we define it here
# FIXME remove these hooks after portage-2.1.1 is stable, as
# it has proper env saving
pre_src_unpack() {
	initialize-java-environment
}

pre_src_compile() {
	initialize-java-environment
}

pre_src_install() {
	initialize-java-environment
}

pre_src_test() {
	initialize-java-environment
}

pre_pkg_preinst() {
	initialize-java-environment
}

pre_pkg_postinst() {
	initialize-java-environment
}


pkglistpath="${T}/java-pkg-list"

java-pkg_doclass()
{
	debug-print-function ${FUNCNAME} $*
	java-pkg_dojar $*
}

java-pkg_do_init_()
{
	debug-print-function ${FUNCNAME} $*

	if [ -z "${JARDESTTREE}" ] ; then
		JARDESTTREE="lib"
		SODESTTREE=$(get_libdir)
	fi

	# Set install paths
	sharepath="${DESTTREE}/share"
	if [ "$SLOT" == "0" ] ; then
		pkg_name="${PN}"
	else
		pkg_name="${PN}-${SLOT}"
	fi

	shareroot="${sharepath}/${pkg_name}"

	if [ -z "${jardest}" ] ; then
		jardest="${shareroot}/${JARDESTTREE}"
	fi

	if [ -z "${sodest}" ] ; then
		sodest="/opt/${pkg_name}/${SODESTTREE}"
	fi

	package_env="${D}${shareroot}/package.env"

	debug-print "JARDESTTREE=${JARDESTTREE}"
	debug-print "SODESTTREE=${SODESTTREE}"
	debug-print "sharepath=${sharepath}"
	debug-print "shareroot=${shareroot}"
	debug-print "jardest=${jardest}"
	debug-print "sodest=${sodest}"
	debug-print "package_env=${package_env}"

}

java-pkg_do_write_()
{
	debug-print-function ${FUNCNAME} $*
	# Create directory for package.env
	dodir "${shareroot}"

	# Create package.env
	echo "DESCRIPTION=${DESCRIPTION}" > "${package_env}"
	echo "GENERATION=1" >> "${package_env}"
	if [ -n "${cp_pkg}" ]; then
		debug-print "cp_prepend: ${cp_prepend}"
		debug-print "cp_pkg: ${cp_pkg}"
		debug-print "cp_append: ${cp_append}"
		echo "CLASSPATH=${cp_prepend}:${cp_pkg}:${cp_append}" >> "${package_env}"
	fi
	if [ -n "${lp_pkg}" ]; then
		echo "LIBRARY_PATH=${lp_prepend}:${lp_pkg}:${lp_append}" >> "${package_env}"
	fi
	if [ -f ${pkglistpath} ] ; then
		pkgs=$(cat ${pkglistpath} | tr '\n' ':')
		echo "DEPEND=${pkgs}" >> "${package_env}"
	fi

	# Strip unnecessary leading and trailing colons
	sed -e "s/=:/=/" -e "s/:$//" -i "${package_env}"
}

java-pkg_do_getsrc_()
{
	# Check for symlink
	if [ -L "${i}" ] ; then
		cp "${i}" "${T}"
		echo "${T}"/`/usr/bin/basename "${i}"`

	# Check for directory
	elif [ -d "${i}" ] ; then
		echo "java-pkg: warning, skipping directory ${i}"
		continue
	else
		echo "${i}"
	fi
}


java-pkg_doso()
{
	debug-print-function ${FUNCNAME} $*
	[ -z "$1" ]

	java-pkg_do_init_

	# Check for arguments
	if [ -z "$*" ] ; then
		die "at least one argument needed"
	fi

	# Make sure directory is created
	if [ ! -d "${D}${sodest}" ] ; then
		install -d "${D}${sodest}"
	fi

	for i in $* ; do
		mysrc=$(java-pkg_do_getsrc_)

		# Install files
		install -m 0755 "${mysrc}" "${D}${sodest}" || die "${mysrc} not found"
	done
	lp_pkg="${sodest}"

	java-pkg_do_write_
}

java-pkg_dojar()
{
	debug-print-function ${FUNCNAME} $*
	[ -z "$1" ]

	java-pkg_do_init_

	if [ -n "${DEP_PREPEND}" ] ; then
		for i in ${DEP_PREPEND}
		do
			if [ -f "${sharepath}/${i}/package.env" ] ; then
				debug-print "${i} path: ${sharepath}/${i}"
				if [ -z "${cp_prepend}" ] ; then
					cp_prepend=`grep "CLASSPATH=" "${sharepath}/${i}/package.env" | sed "s/CLASSPATH=//"`
				else
					cp_prepend="${cp_prepend}:"`grep "CLASSPATH=" "${sharepath}/${i}/package.env" | sed "s/CLASSPATH=//"`
				fi
			else
				debug-print "Error:  Package ${i} not found."
				debug-print "${i} path: ${sharepath}/${i}"
				die "Error in DEP_PREPEND."
			fi
			debug-print "cp_prepend=${cp_prepend}"

		done
	fi

	if [ -n "${DEP_APPEND}" ] ; then
		for i in ${DEP_APPEND}
		do
			if [ -f "${sharepath}/${i}/package.env" ] ; then
				debug-print "${i} path: ${sharepath}/${i}"
				# Before removing the quotes this caused
				# https://bugs.gentoo.org/show_bug.cgi?id=155590
				# There was also an extra quote in the else that could also be
				# the cause.
				if [ -z "${cp_append}" ] ; then
					cp_append=$(grep "CLASSPATH=" "${sharepath}/${i}/package.env" \
						| sed -e "s/CLASSPATH=//" -e 's/"//g')
				else
					cp_append="${cp_append}:$(grep "CLASSPATH=" \
					"${sharepath}/${i}/package.env" \
						| sed -e "s/CLASSPATH=//" -e 's/"//g')"
				fi
			else
				debug-print "Error:  Package ${i} not found."
				debug-print "${i} path: ${sharepath}/${i}"
				die "Error in DEP_APPEND."
			fi
			debug-print "cp_append=${cp_append}"
		done
	fi

	# Check for arguments
	if [ -z "$*" ] ; then
		die "at least one argument needed"
	fi

	# Make sure directory is created
	dodir ${jardest}

	for i in $* ; do
		mysrc=$(java-pkg_do_getsrc_)

		# Install files
		install -m 0644 "${mysrc}" "${D}${jardest}" || die "${mysrc} not found"

		# Build CLASSPATH
		if [ -z "${cp_pkg}" ] ; then
			cp_pkg="${jardest}"/`/usr/bin/basename "${i}"`
		else
			cp_pkg="${cp_pkg}:${jardest}/"`/usr/bin/basename "${i}"`
		fi
	done

	java-pkg_do_write_
}

java-pkg_newjar()
{
	if [ -z "${T}" ] || [ -z "${2}" ] ; then
		die "java-pkg_newjar: Nothing defined to do"
	fi

	rm -rf "${T}/${2}"
	cp "${1}" "${T}/${2}"
	java-pkg_dojar "${T}/${2}"
}

java-pkg_dowar()
{
	debug-print-function ${FUNCNAME} $*
	[ -z "$1" ]

	# Check for arguments
	if [ -z "$*" ] ; then
		die "at least one argument needed"
	fi

	if [ -z "${WARDESTTREE}" ] ; then
		WARDESTTREE="webapps"
	fi

	sharepath="${DESTTREE}/share"
	shareroot="${sharepath}/${PN}"
	wardest="${shareroot}/${WARDESTTREE}"

	debug-print "WARDESTTREE=${WARDESTTREE}"
	debug-print "sharepath=${sharepath}"
	debug-print "shareroot=${shareroot}"
	debug-print "wardest=${wardest}"

	# Patch from Joerg Schaible <joerg.schaible@gmx.de>
	# Make sure directory is created
	if [ ! -d "${D}${wardest}" ] ; then
		install -d "${D}${wardest}"
	fi

	for i in $* ; do
		# Check for symlink
		if [ -L "${i}" ] ; then
			cp "${i}" "${T}"
			mysrc="${T}"/`/usr/bin/basename "${i}"`

		# Check for directory
		elif [ -d "${i}" ] ; then
			echo "dowar: warning, skipping directory ${i}"
			continue
		else
			mysrc="${i}"
		fi

		# Install files
		install -m 0644 "${mysrc}" "${D}${wardest}"
	done
}

java-pkg_dozip()
{
	debug-print-function ${FUNCNAME} $*
	java-pkg_dojar $*
}

_record-jar()
{
	echo "$(basename $2)@$1" >> ${pkglistpath}
}

java-pkg_jarfrom() {
	java-pkg_jar-from "$@"
}

java-pkg_jar-from()
{
	debug-print-function ${FUNCNAME} $*

	local pkg=$1
	local jar=$2
	local destjar=$3

	if [ -z "${destjar}" ] ; then
		destjar=${jar}
	fi

	for x in $(java-config --classpath=${pkg} | tr ':' ' '); do
		if [ ! -f ${x} ] ; then
			die "Installation problems with jars in ${pkg} - is it installed?"
			return 1
		fi
		_record-jar ${pkg} ${x}
		if [ -z "${jar}" ] ; then
			[[ -f $(basename ${x}) ]]  && rm $(basename ${x})
			ln -snf ${x} $(basename ${x})
		elif [ "$(basename ${x})" == "${jar}" ] ; then
			[[ -f ${destjar} ]]  && rm ${destjar}
			ln -snf ${x} ${destjar}
			return 0
		fi
	done
	if [ -z "${jar}" ] ; then
		return 0
	else
		die "failed to find ${jar}"
	fi
}

java-pkg_getjar()
{

	debug-print-function ${FUNCNAME} $*

	local pkg=$1
	local jar=$2

	for x in $(java-config --classpath=${pkg} | tr ':' ' '); do

		if [ ! -f ${x} ] ; then
			die "Installation problems with jars in ${pkg} - is it installed?"
		fi

		_record-jar ${pkg} ${x}

		if [ "$(basename ${x})" == "${jar}" ] ; then
			echo ${x}
			return 0
		fi
	done
	die "Could not find $2 in $1"
}

java-pkg_getjars()
{
	java-config --classpath=$1
}


java-pkg_dohtml()
{
	dohtml -f package-list $@
}

java-pkg_jarinto()
{
	jardest=$1
}

java-pkg_sointo()
{
	sodest=$1
}

java-pkg_dosrc() {
	java-pkg_do_init_

	[ $# -lt 1 ] && die "${FUNCNAME[0]}: at least one argument needed"

	local target="${shareroot}/source/"

	local files
	local startdir=$(pwd)
	for x in ${@}; do
		cd $(dirname ${x})
		zip -q -r ${T}/${PN}-src.zip $(basename ${x}) -i '*.java'
		local res=$?
		if [[ ${res} != 12 && ${res} != 0 ]]; then
			die "zip failed"
		fi

		cd ${startdir}
	done

	dodir ${target}
	install ${INSOPTIONS} "${T}/${PN}-src.zip" "${D}${target}" \
		|| die "failed to install sources"
}


java-pkg_announce-qa-violation() {
	if hasq java-strict ${FEATURES}; then
		echo "Java QA Notice: $@" >&2
	fi
}
