# eclass for ant based Java packages
#
# Copyright (c) 2004-2005, Thomas Matthijs <axxo@gentoo.org>
# Copyright (c) 2004-2005, Gentoo Foundation
# Changes:
#   December 2006:
#     I pretty much rewrote the logic of the bsfix functions
#     and xml-rewrite.py because they were so slow
#     Petteri Räty (betelgeuse@gentoo.org)
#
# Licensed under the GNU General Public License, v2
#
# $Header: /var/cvsroot/gentoo-x86/eclass/java-ant-2.eclass,v 1.11 2007/01/06 19:45:27 betelgeuse Exp $

inherit java-utils-2

# This eclass provides functionality for Java packages which use
# ant to build. In particular, it will attempt to fix build.xml files, so that
# they use the appropriate 'target' and 'source' attributes.

# We need some tools from javatoolkit. We also need portage 2.1 for phase hooks
DEPEND=">=dev-java/javatoolkit-0.1.5 ${JAVA_PKG_PORTAGE_DEP}"

# ------------------------------------------------------------------------------
# @global JAVA_PKG_BSFIX
#
# Should we attempt to 'fix' ant build files to include the source/target
# attributes when calling javac?
#
# default: on
# ------------------------------------------------------------------------------
JAVA_PKG_BSFIX=${JAVA_PKG_BSFIX:-"on"}

# ------------------------------------------------------------------------------
# @global JAVA_PKG_BSFIX_ALL
#
# If we're fixing build files, should we try to fix all the ones we can find?
#
# default: yes
# ------------------------------------------------------------------------------
JAVA_PKG_BSFIX_ALL=${JAVA_PKG_BSFIX_ALL:-"yes"}

# ------------------------------------------------------------------------------
# @global JAVA_PKG_BSFIX_NAME
#
# Filename of build files to fix/search for
#
# default: build.xml
# ------------------------------------------------------------------------------
JAVA_PKG_BSFIX_NAME=${JAVA_PKG_BSFIX_NAME:-"build.xml"}

# ------------------------------------------------------------------------------
# @global JAVA_PKG_BSFIX_TARGETS_TAGS
#
# Targets to fix the 'source' attribute in
#
# default: javac xjavac javac.preset
# ------------------------------------------------------------------------------
JAVA_PKG_BSFIX_TARGET_TAGS=${JAVA_PKG_BSFIX_TARGET_TAGS:-"javac xjavac javac.preset"}

# ------------------------------------------------------------------------------
# @global JAVA_PKG_BSFIX_SOURCE_TAGS
#
# Targets to fix the 'target' attribute in
#
# default: javacdoc javac xjavac javac.preset
# ------------------------------------------------------------------------------
JAVA_PKG_BSFIX_SOURCE_TAGS=${JAVA_PKG_BSFIX_SOURCE_TAGS:-"javadoc javac xjavac javac.preset"}

# ------------------------------------------------------------------------------
# @public java-ant_src_unpack
#
# Unpacks the source, and attempts to fix build files.
# ------------------------------------------------------------------------------
post_src_unpack() {
	if java-pkg_func-exists ant_src_unpack; then
		java-pkg_announce-qa-violation "Using old ant_src_unpack. Should be src_unpack"
		ant_src_unpack
	fi
	java-ant_bsfix
}

# ------------------------------------------------------------------------------
# @private ant_src_unpack
#
# Helper function which does the actual unpacking
# ------------------------------------------------------------------------------
# TODO maybe use base.eclass for some patching love?
#ant_src_unpack() {
#	debug-print-function ${FUNCNAME} $*
#	if [[ -n "${A}" ]]; then
#		unpack ${A}
#	fi
#}

# ------------------------------------------------------------------------------
# @private java-ant_bsfix
#
# Attempts to fix build files. The following variables will affect its behavior
# as listed above:
# 	JAVA_PKG_BSFIX
#	JAVA_PKG_BSFIX_ALL
#	JAVA_PKG_BSFIX_NAME,
# ------------------------------------------------------------------------------
java-ant_bsfix() {
	debug-print-function ${FUNCNAME} $*

	[[ "${JAVA_PKG_BSFIX}" != "on" ]] && return
	if ! java-pkg_needs-vm; then
		echo "QA Notice: Package is using java-ant, but doesn't depend on a Java VM"
	fi

	pushd "${S}" >/dev/null

	local find_args=""
	[[ "${JAVA_PKG_BSFIX_ALL}" == "yes" ]] || find_args="-maxdepth 1"

	find_args="${find_args} -type f -name ${JAVA_PKG_BSFIX_NAME// / -o -name } "

	# This voodoo is done for paths with spaces
	local bsfix_these
	while read line; do
		[[ -z ${line} ]] && continue
		bsfix_these="${bsfix_these} '${line}'"
	done <<-EOF
			$(find . ${find_args})
		EOF

	[[ "${bsfix_these// /}" ]] && eval java-ant_bsfix_files ${bsfix_these}

	popd > /dev/null
}

_bsfix_die() {
	if has_version dev-python/pyxml; then
		eerror "If the output above contains:"
		eerror "ImportError:"
		eerror "/usr/lib/python2.4/site-packages/_xmlplus/parsers/pyexpat.so:"
		eerror "undefined symbol: PyUnicodeUCS2_DecodeUTF8"
		eerror "Try re-emerging dev-python/pyxml"
		die ${1} " Look at the eerror message above"
	else
		die ${1}
	fi
}

# ------------------------------------------------------------------------------
# @public java-ant_bsfix_files
#
# Attempts to fix named build files. The following variables will affect its behavior
# as listed above:
#	JAVA_PKG_BSFIX_SOURCE_TAGS
#	JAVA_PKG_BSFIX_TARGET_TAGS
#
# When changing this function, make sure that it works with paths with spaces in
# them.
# ------------------------------------------------------------------------------
java-ant_bsfix_files() {
	debug-print-function ${FUNCNAME} $*

	[[ ${#} = 0 ]] && die "${FUNCNAME} called without arguments"

	local want_source="$(java-pkg_get-source)"
	local want_target="$(java-pkg_get-target)"

	debug-print "${FUNCNAME}: target: ${want_target} source: ${want_source}"

	if [ -z "${want_source}" -o -z "${want_target}" ]; then
		eerror "Could not find valid -source/-target values"
		eerror "Please file a bug about this on bugs.gentoo.org"
		die "Could not find valid -source/-target values"
	else
		local files

		[[ -x "/usr/bin/xml-rewrite-2.py" ]] && local using_new="true"

		for file in "${@}"; do
			debug-print "${FUNCNAME}: ${file}"

			if [[ -n "${JAVA_PKG_DEBUG}" ]]; then
				cp "${file}" "${file}.orig" || die "failed to copy ${file}"
			fi

			if [[ ! -w "${file}" ]]; then
				chmod u+w "${file}" || die "chmod u+w ${file} failed"
			fi

			files="${files} -f '${file}'"

			if [[ -z "${using_new}" ]]; then
				vecho "Rewriting $file (using xml-rewrite.py)"
				# Doing this twice because otherwise the source attributes would
				# get added to target tags too and javadoc does not like target
				xml-rewrite.py -f "${file}" \
					-c -e ${JAVA_PKG_BSFIX_SOURCE_TAGS// / -e } \
					-a source -v ${want_source} || _bsfix_die "xml-rewrite failed: ${file}"
				xml-rewrite.py -f "${file}" \
					-c -e ${JAVA_PKG_BSFIX_TARGET_TAGS// / -e } \
					-a target -v ${want_target} || _bsfix_die "xml-rewrite failed: ${file}"
			fi
		done

		if [[ "${using_new}" ]]; then
			quiet_mode && local output=">/dev/null"
			vecho "Rewriting source attributes"
			eval xml-rewrite-2.py ${files} \
				-c -e ${JAVA_PKG_BSFIX_SOURCE_TAGS// / -e } \
				-a source -v ${want_source} ${output} || _bsfix_die "xml-rewrite2 failed: ${file}"

			vecho "Rewriting target attributes"
			eval xml-rewrite-2.py ${files} \
				-c -e ${JAVA_PKG_BSFIX_TARGET_TAGS// / -e } \
				-a target -v ${want_target} ${output} || _bsfix_die "xml-rewrite2 failed: ${file}"
		fi

		if [[ -n "${JAVA_PKG_DEBUG}" ]]; then
			for file in "${@}"; do
				diff -NurbB "${file}.orig" "${file}"
			done
		fi
	fi
}


# ------------------------------------------------------------------------------
# @public java-ant_bsfix_one
#
# Attempts to fix named build file. The following variables will affect its behavior
# as listed above:
#	JAVA_PKG_BSFIX_SOURCE_TAGS
#	JAVA_PKG_BSFIX_TARGET_TAGS
# ------------------------------------------------------------------------------
java-ant_bsfix_one() {
	debug-print-function ${FUNCNAME} $*

	if [ -z "${1}" ]; then
		eerror "${FUNCNAME} needs one argument"
		die "${FUNCNAME} needs one argument"
	fi

	java-ant_bsfix_files "${1}"
}

# ------------------------------------------------------------------------------
# @public java-ant_rewrite-classpath
#
# Adds 'classpath="${gentoo.classpath}"' to specified build file.
# ------------------------------------------------------------------------------
java-ant_rewrite-classpath() {
	debug-print-function ${FUNCNAME} $*

	if [ -z "${1}" ]; then
		eerror "java-ant_rewrite-classpath needs one argument"
		die "java-ant_rewrite-classpath needs one argument"
	fi

	local file="${1}"
	echo "Adding gentoo.classpath to ${file}"
	debug-print "java-ant_rewrite-classpath: ${file}"

	cp "${file}" "${file}.orig" || die "failed to copy ${file}"

	chmod u+w "${file}"

	xml-rewrite.py -f "${file}" --change -e javac -e xjavac -a classpath -v '${gentoo.classpath}' || die "xml-rewrite failed: ${file}"

	if [[ -n "${JAVA_PKG_DEBUG}" ]]; then
		diff -NurbB "${file}.orig" "${file}"
	fi
}
