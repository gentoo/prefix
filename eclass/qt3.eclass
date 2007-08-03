# Copyright 2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/qt3.eclass,v 1.30 2007/08/02 20:04:40 carlo Exp $
#
# Author Caleb Tennis <caleb@gentoo.org>
#
# This eclass is simple.  Inherit it, and in your depend, do something like this:
#
# DEPEND="$(qt_min_version 3.1)"
#
# and it handles the rest for you
#
# Caveats:
#
# Currently, the ebuild assumes that a minimum version of Qt3 is NOT satisfied by Qt4

inherit toolchain-funcs versionator

IUSE="${IUSE}"

QTPKG="x11-libs/qt-"
QT3MAJORVERSIONS="3.3 3.2 3.1 3.0"
QT3VERSIONS="3.3.8-r3 3.3.8-r2 3.3.8-r1 3.3.8 3.3.6-r5 3.3.6-r4 3.3.6-r3 3.3.6-r2 3.3.6-r1 3.3.6 3.3.5-r1 3.3.5 3.3.4-r9 3.3.4-r8 3.3.4-r7 3.3.4-r6 3.3.4-r5 3.3.4-r4 3.3.4-r3 3.3.4-r2 3.3.4-r1 3.3.4 3.3.3-r3 3.3.3-r2 3.3.3-r1 3.3.3 3.3.2 3.3.1-r2 3.3.1-r1 3.3.1 3.3.0-r1 3.3.0 3.2.3-r1 3.2.3 3.2.2-r1 3.2.2 3.2.1-r2 3.2.1-r1 3.2.1 3.2.0 3.1.2-r4 3.1.2-r3 3.1.2-r2 3.1.2-r1 3.1.2 3.1.1-r2 3.1.1-r1 3.1.1 3.1.0-r3 3.1.0-r2 3.1.0-r1 3.1.0"

if [[ -z "${QTDIR}" ]]; then
	QTDIR="/usr/qt/3"
fi

PATH="${QTDIR}/bin:${PATH}"

addwrite "${QTDIR}/etc/settings"
addpredict "${QTDIR}/etc/settings"

qt_min_version() {
	local list=$(qt_min_version_list "$@")
	if [[ ${list%% *} == "${list}" ]]; then
		echo "${list}"
	else
		echo "|| ( ${list} )"
	fi
}

qt_min_version_list() {
	local MINVER="$1"
	local VERSIONS=""

	case "${MINVER}" in
		3|3.0|3.0.0) VERSIONS="=${QTPKG}3*";;
		3.1|3.1.0|3.2|3.2.0|3.3|3.3.0)
			for x in ${QT3MAJORVERSIONS}; do
				if $(version_is_at_least "${MINVER}" "${x}"); then
					VERSIONS="${VERSIONS} =${QTPKG}${x}*"
				fi
			done
			;;
		3*)
			for x in ${QT3VERSIONS}; do
				if $(version_is_at_least "${MINVER}" "${x}"); then
					VERSIONS="${VERSIONS} =${QTPKG}${x}"
				fi
			done
			;;
		*) VERSIONS="=${QTPKG}3*";;
	esac

	echo ${VERSIONS}
}

eqmake3() {
	local LOGFILE="${T}/qmake-$$.out"
	local projprofile="${1}"
	[ -z ${projprofile} ] && projprofile="${PN}.pro"
	shift 1

	ebegin "Processing qmake ${projprofile}"

	# file exists?
	if [ ! -f ${projprofile} ]; then
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

	# some standard config options
	local configoptplus="CONFIG += no_fixpath"
	local configoptminus="CONFIG -="
	if has debug ${IUSE} && use debug; then
		configoptplus="${configoptplus} debug"
		configoptminus="${configoptminus} release"
	else
		configoptplus="${configoptplus} release"
		configoptminus="${configoptminus} debug"
	fi

	${QTDIR}/bin/qmake ${projprofile} \
		QMAKE=${QTDIR}/bin/qmake \
		QMAKE_CC=$(tc-getCC) \
		QMAKE_CXX=$(tc-getCXX) \
		QMAKE_LINK=$(tc-getCXX) \
		QMAKE_CFLAGS_RELEASE="${CFLAGS}" \
		QMAKE_CFLAGS_DEBUG="${CFLAGS}" \
		QMAKE_CXXFLAGS_RELEASE="${CXXFLAGS}" \
		QMAKE_CXXFLAGS_DEBUG="${CXXFLAGS}" \
		QMAKE_LFLAGS_RELEASE="${LDFLAGS}" \
		QMAKE_LFLAGS_DEBUG="${LDFLAGS}" \
		"${configoptminus}" \
		"${configoptplus}" \
		QMAKE_RPATH= \
		${@} >> ${LOGFILE} 2>&1

	local result=$?
	eend ${result}

	# was qmake successful?
	if [ ${result} -ne 0 ]; then
		echo
		eerror "Running qmake on \"${projprofile}\" has failed"
		echo
		eerror "This shouldn't happen - please send a bug report to bugs.gentoo.org"
		echo
		die "qmake failed on ${projprofile}"
	fi

	return ${result}
}
