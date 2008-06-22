# Copyright 2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/qt4.eclass,v 1.41 2008/06/21 15:12:48 swegener Exp $

# @ECLASS: qt4.eclass
# @MAINTAINER:
# Caleb Tennis <caleb@gentoo.org>
# @BLURB: Eclass for Qt4 packages
# @DESCRIPTION:
# This eclass contains various functions that may be useful
# when dealing with packages using Qt4 libraries.

# 08.16.06 - Renamed qt_min_* to qt4_min_* to avoid conflicts with the qt3 eclass.
#    - Caleb Tennis <caleb@gentoo.org>

inherit eutils multilib toolchain-funcs versionator

QTPKG="x11-libs/qt-"
QT4MAJORVERSIONS="4.4 4.3 4.2 4.1 4.0"
QT4VERSIONS="4.4.0 4.4.0_beta1 4.4.0_rc1 4.3.4-r1 4.3.4 4.3.3 4.3.2-r1 4.3.2 4.3.1-r1 4.3.1 4.3.0-r2 4.3.0-r1 4.3.0 4.3.0_rc1 4.3.0_beta1 4.2.3-r1 4.2.3 4.2.2 4.2.1 4.2.0-r2 4.2.0-r1 4.2.0 4.1.4-r2 4.1.4-r1 4.1.4 4.1.3 4.1.2 4.1.1 4.1.0 4.0.1 4.0.0"

# @FUNCTION: qt4_min_version
# @USAGE: [minimum version]
# @DESCRIPTION:
# This function should be called in package DEPENDs whenever it depends on qt4.
# Simple example - in your depend, do something like this:
# DEPEND="$(qt4_min_version 4.2)"
# if the package can be build with qt-4.2 or higher.
#
# For builds that use an EAPI with support for SLOT dependencies, this will
# return a SLOT dependency, rather than a list of versions.
qt4_min_version() {
	case ${EAPI:-0} in
		# EAPIs without SLOT dependencies
		0)	echo "|| ("
			qt4_min_version_list "$@"
			echo ")"
			;;
		# EAPIS with SLOT dependencies.
		*)	echo ">=${QTPKG}${1}:4"
			;;
	esac
}

qt4_min_version_list() {
	local MINVER="$1"
	local VERSIONS=""

	case "${MINVER}" in
		4|4.0|4.0.0) VERSIONS="=${QTPKG}4*";;
		4.1|4.1.0|4.2|4.2.0|4.3|4.3.0|4.4|4.4.0)
			for x in ${QT4MAJORVERSIONS}; do
				if version_is_at_least "${MINVER}" "${x}"; then
					VERSIONS="${VERSIONS} =${QTPKG}${x}*"
				fi
			done
			;;
		4*)
			for x in ${QT4VERSIONS}; do
				if version_is_at_least "${MINVER}" "${x}"; then
					VERSIONS="${VERSIONS} =${QTPKG}${x}"
				fi
			done
			;;
		*) VERSIONS="=${QTPKG}4*";;
	esac

	echo "${VERSIONS}"
}

# @FUNCTION: qt4_pkg_setup
# @MAINTAINER:
# Caleb Tennis <caleb@gentoo.org>
# Przemyslaw Maciag <troll@gentoo.org>
# @DESCRIPTION:
# Default pkg_setup function for packages that depends on qt4. If you have to
# create ebuilds own pkg_setup in your ebuild, call qt4_pkg_setup in it.
# This function uses two global vars from ebuild:
# - QT4_BUILT_WITH_USE_CHECK - contains use flags that need to be turned on for
#   =x11-libs/qt-4*
# - QT4_OPTIONAL_BUILT_WITH_USE_CHECK - qt4 flags that provides some
#   functionality, but can alternatively be disabled in ${CATEGORY}/${PN}
#   (so qt4 don't have to be recompiled)
#
# flags to watch for for Qt4.4:
# zlib png | opengl dbus qt3support | sqlite3 ssl
qt4_pkg_setup() {

	QT4_BEST_VERSION="$(best_version =x11-libs/qt-4*)"
	QT4_MINOR_VERSION="$(get_version_component_range 2 ${QT4_BEST_VERSION/*qt-/})"

	local requiredflags=""
	for x in ${QT4_BUILT_WITH_USE_CHECK}; do
		if [[ "${QT4_MINOR_VERSION}" -ge 4 ]]; then
		# The use flags are different in 4.4 and above, and it's a split package, so this is used to catch
		# the various use flag combos specified in the ebuilds to make sure we don't error out.

			if [[ ${x} == zlib || ${x} == png ]]; then
				# Qt 4.4+ is built with zlib and png by default, so the use flags aren't needed
				continue;
			elif [[ ${x} == opengl || ${x} == dbus || ${x} == qt3support ]]; then
				# Make sure the qt-${x} package has been already installed

				if ! has_version x11-libs/qt-${x}; then
					eerror "You must first install the x11-libs/qt-${x} package."
					die "Install x11-libs/qt-${x}"
				fi
			elif [[ ${x} == ssl ]]; then
				if ! has_version x11-libs/qt-core || ! built_with_use x11-libs/qt-core ssl; then
					eerror "You must first install the x11-libs/qt-core package with the ssl flag enabled."
					die "Install x11-libs/qt-core with USE=\"ssl\""
				fi
			elif [[ ${x} == sqlite3 ]]; then
				if ! has_version x11-libs/qt-sql || ! built_with_use x11-libs/qt-sql sqlite; then
					eerror "You must first install the x11-libs/qt-sql package with the sqlite flag enabled."
					die "Install x11-libs/qt-sql with USE=\"sqlite\""
				fi
			fi
		elif ! built_with_use =x11-libs/qt-4* ${x}; then
			requiredflags="${requiredflags} ${x}"
		fi
	done

	local optionalflags=""
	for x in ${QT4_OPTIONAL_BUILT_WITH_USE_CHECK}; do
		if use ${x} && ! built_with_use =x11-libs/qt-4* ${x}; then
			optionalflags="${optionalflags} ${x}"
		fi
	done

	local diemessage=""
	if [[ ${requiredflags} != "" ]]; then
		eerror
		eerror "(1) In order to compile ${CATEGORY}/${PN} first you need to build"
		eerror "=x11-libs/qt-4* with USE=\"${requiredflags}\" flag(s)"
		eerror
		diemessage="(1) recompile qt4 with \"${requiredflags}\" USE flag(s) ; "
	fi
	if [[ ${optionalflags} != "" ]]; then
		eerror
		eerror "(2) You are trying to compile ${CATEGORY}/${PN} package with"
		eerror "USE=\"${optionalflags}\""
		eerror "while qt4 is built without this particular flag(s): it will"
		eerror "not work."
		eerror
		eerror "Possible solutions to this problem are:"
		eerror "a) install package ${CATEGORY}/${PN} without \"${optionalflags}\" USE flag(s)"
		eerror "b) re-emerge qt4 with \"${optionalflags}\" USE flag(s)"
		eerror
		diemessage="${diemessage}(2) recompile qt4 with \"${optionalflags}\" USE flag(s) or disable them for ${PN} package\n"
	fi

	[[ ${diemessage} != "" ]] && die "can't emerge ${CATEGORY}/${PN}: ${diemessage}"
}

# @FUNCTION: eqmake4
# @USAGE: [.pro file] [additional parameters to qmake]
# @MAINTAINER:
# Przemyslaw Maciag <troll@gentoo.org>
# Davide Pesavento <davidepesa@gmail.com>
# @DESCRIPTION:
# Runs qmake on the specified .pro file (defaults to
# ${PN}.pro if eqmake4 was called with no argument).
# Additional parameters are passed unmodified to qmake.
eqmake4() {
	local LOGFILE="${T}/qmake-$$.out"
	local projprofile="${1}"
	[[ -z ${projprofile} ]] && projprofile="${PN}.pro"
	shift 1

	ebegin "Processing qmake ${projprofile}"

	# file exists?
	if [[ ! -f ${projprofile} ]]; then
		echo
		eerror "Project .pro file \"${projprofile}\" does not exists"
		eerror "qmake cannot handle non-existing .pro files"
		echo
		eerror "This shouldn't happen - please send a bug report to bugs.gentoo.org"
		echo
		die "Project file not found in ${PN} sources"
	fi

	echo >> ${LOGFILE}
	echo "******  qmake ${projprofile}  ******" >> ${LOGFILE}
	echo >> ${LOGFILE}

	# as a workaround for broken qmake, put everything into file
	if has debug ${IUSE} && use debug; then
		echo -e "\nCONFIG -= release\nCONFIG += no_fixpath debug" >> ${projprofile}
	else
		echo -e "\nCONFIG -= debug\nCONFIG += no_fixpath release" >> ${projprofile}
	fi

	"${EPREFIX}"/usr/bin/qmake ${projprofile} \
		QTDIR="${EPREFIX}"/usr/$(get_libdir) \
		QMAKE="${EPREFIX}"/usr/bin/qmake \
		QMAKE_CC=$(tc-getCC) \
		QMAKE_CXX=$(tc-getCXX) \
		QMAKE_LINK=$(tc-getCXX) \
		QMAKE_CFLAGS_RELEASE="${CFLAGS}" \
		QMAKE_CFLAGS_DEBUG="${CFLAGS}" \
		QMAKE_CXXFLAGS_RELEASE="${CXXFLAGS}" \
		QMAKE_CXXFLAGS_DEBUG="${CXXFLAGS}" \
		QMAKE_LFLAGS_RELEASE="${LDFLAGS}" \
		QMAKE_LFLAGS_DEBUG="${LDFLAGS}" \
		QMAKE_RPATH= \
		"${@}" >> ${LOGFILE} 2>&1

	local result=$?
	eend ${result}

	# was qmake successful?
	if [[ ${result} -ne 0 ]]; then
		echo
		eerror "Running qmake on \"${projprofile}\" has failed"
		echo
		eerror "This shouldn't happen - please send a bug report to bugs.gentoo.org"
		echo
		die "qmake failed on ${projprofile}"
	fi

	return ${result}
}

EXPORT_FUNCTIONS pkg_setup
