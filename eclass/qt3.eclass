# Copyright 2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/qt3.eclass,v 1.21 2006/10/20 17:58:55 flameeyes Exp $
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

inherit versionator

QTPKG="x11-libs/qt-"
QT3MAJORVERSIONS="3.3 3.2 3.1 3.0"
QT3VERSIONS="3.3.6-r4 3.3.6-r3 3.3.6-r2 3.3.6-r1 3.3.6 3.3.5-r1 3.3.5 3.3.4-r9 3.3.4-r8 3.3.4-r7 3.3.4-r6 3.3.4-r5 3.3.4-r4 3.3.4-r3 3.3.4-r2 3.3.4-r1 3.3.4 3.3.3-r3 3.3.3-r2 3.3.3-r1 3.3.3 3.3.2 3.3.1-r2 3.3.1-r1 3.3.1 3.3.0-r1 3.3.0 3.2.3-r1 3.2.3 3.2.2-r1 3.2.2 3.2.1-r2 3.2.1-r1 3.2.1 3.2.0 3.1.2-r4 3.1.2-r3 3.1.2-r2 3.1.2-r1 3.1.2 3.1.1-r2 3.1.1-r1 3.1.1 3.1.0-r3 3.1.0-r2 3.1.0-r1 3.1.0"

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
