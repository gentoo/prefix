# Copyright 2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/qt4.eclass,v 1.27 2007/10/03 14:59:04 caleb Exp $
#
# Author Caleb Tennis <caleb@gentoo.org>
#
# This eclass is simple.  Inherit it, and in your depend, do something like this:
#
# DEPEND="$(qt4_min_version 4)"
#
# and it handles the rest for you
#
# 08.16.06 - Renamed qt_min_* to qt4_min_* to avoid conflicts with the qt3 eclass.
#    - Caleb Tennis <caleb@gentoo.org>

inherit eutils multilib toolchain-funcs versionator

IUSE="${IUSE}"

QTPKG="x11-libs/qt-"
QT4MAJORVERSIONS="4.3 4.2 4.1 4.0"
QT4VERSIONS="4.3.2 4.3.1-r1 4.3.1 4.3.0-r2 4.3.0-r1 4.3.0 4.3.0_rc1 4.3.0_beta1 4.2.3-r1 4.2.3 4.2.2 4.2.1 4.2.0-r2 4.2.0-r1 4.2.0 4.1.4-r2 4.1.4-r1 4.1.4 4.1.3 4.1.2 4.1.1 4.1.0 4.0.1 4.0.0"

qt4_min_version() {
	echo "|| ("
	qt4_min_version_list "$@"
	echo ")"
}

qt4_min_version_list() {
	local MINVER="$1"
	local VERSIONS=""

	case "${MINVER}" in
		4|4.0|4.0.0) VERSIONS="=${QTPKG}4*";;
		4.1|4.1.0|4.2|4.2.0)
			for x in ${QT4MAJORVERSIONS}; do
				if $(version_is_at_least "${MINVER}" "${x}"); then
					VERSIONS="${VERSIONS} =${QTPKG}${x}*"
				fi
			done
			;;
		4*)
			for x in ${QT4VERSIONS}; do
				if $(version_is_at_least "${MINVER}" "${x}"); then
					VERSIONS="${VERSIONS} =${QTPKG}${x}"
				fi
			done
			;;
		*) VERSIONS="=${QTPKG}4*";;
	esac

	echo "${VERSIONS}"
}

qt4_pkg_setup() {
	for x in ${QT4_BUILT_WITH_USE_CHECK}; do
		if ! built_with_use =x11-libs/qt-4* $x; then
			die "This package requires Qt4 to be built with the '${x}' use flag."
		fi
	done
}

eqmake4() {
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

	# as a workaround for broken qmake, put everything into file
	if has debug ${IUSE} && use debug; then
		echo -e "$CONFIG -= release\nCONFIG += no_fixpath debug" >> ${projprofile}
	else
		echo -e "$CONFIG -= debug\nCONFIG += no_fixpath release" >> ${projprofile}
	fi

	/usr/bin/qmake ${projprofile} \
		QTDIR=/usr/$(get_libdir) \
		QMAKE=/usr/bin/qmake \
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

EXPORT_FUNCTIONS pkg_setup
