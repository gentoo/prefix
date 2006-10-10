# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/rpm.eclass,v 1.15 2006/06/27 06:49:09 vapier Exp $

# Author : Alastair Tse <liquidx@gentoo.org> (21 Jun 2003)
#
# Convienence class for extracting RPMs
#
# Basically, rpm_src_unpack does:
#
# 1. uses rpm_unpack to unpack a rpm file using rpmoffset and cpio
# 2. if it is a source rpm, it finds all .tar .tar.gz, .tgz, .tbz2, .tar.bz2,
#    .zip, .ZIP and unpacks them using unpack() (with a little hackery)
# 3. deletes all the unpacked tarballs and zip files from ${WORKDIR}
#
# This ebuild now re-defines a utility function called rpm_unpack which
# basically does what rpm2targz does, except faster. It does not gzip the
# output tar again but directly extracts to ${WORKDIR}
#
# It will autodetect for rpm2cpio (included in app-arch/rpm) and if it exists
# it will use that instead of the less reliable rpmoffset. This means if a
# particular rpm cannot be read using rpmoffset, you just need to put :
#
# DEPEND="app-arch/rpm"
#
# in your ebuild and it will install and use rpm2cpio instead. If you wish
# to force your ebuild to use rpmoffset in the presence of rpm2cpio, define:
#
# USE_RPMOFFSET_ONLY="1"


USE_RPMOFFSET_ONLY=${USE_RPMOFFSET_ONLY-""}

DEPEND=">=app-arch/rpm2targz-9.0-r1"

# extracts the contents of the RPM in ${WORKDIR}
rpm_unpack() {
	local rpmfile rpmoff decompcmd
	rpmfile=$1
	if [ -z "${rpmfile}" ]; then
		return 1
	fi
	if [ -x /usr/bin/rpm2cpio -a -z "${USE_RPMOFFSET_ONLY}" ]; then
		rpm2cpio ${rpmfile} | cpio -idmu --no-preserve-owner --quiet || return 1
	else
		rpmoff=`rpmoffset < ${rpmfile}`
		[ -z "${rpmoff}" ] && return 1

		decompcmd="gzip -dc"
		if [ -n "`dd if=${rpmfile} skip=${rpmoff} bs=1 count=3 2>/dev/null | file - | grep bzip2`" ]; then
			decompcmd="bzip2 -dc"
		fi
		dd ibs=${rpmoff} skip=1 if=${rpmfile} 2> /dev/null \
			| ${decompcmd} \
			| cpio -idmu --no-preserve-owner --quiet || return 1
	fi

	return 0
}

rpm_src_unpack() {
	local x prefix ext myfail OLD_DISTDIR

	for x in ${A}; do
		myfail="failure unpacking ${x}"
		ext=${x##*.}
		case "$ext" in
		rpm)
			echo ">>> Unpacking ${x} to ${WORKDIR}"
			prefix=${x%.rpm}
			cd ${WORKDIR}
			rpm_unpack ${DISTDIR}/${x} || die "${myfail}"

			# find all tar.gz files and extract for srpms
			if [ "${prefix##*.}" = "src" ]; then
				OLD_DISTDIR=${DISTDIR}
				DISTDIR=${WORKDIR}
				findopts="* -maxdepth 0 -name *.tar"
				for t in *.tar.gz *.tgz *.tbz2 *.tar.bz2 *.zip *.ZIP; do
					findopts="${findopts} -o -name ${t}"
				done
				for t in $(find ${findopts} | xargs); do
					unpack ${t}
					rm -f ${t}
				done
				DISTDIR=${OLD_DISTDIR}
			fi
			;;
		*)
			unpack ${x}
			;;
		esac
	done
}

EXPORT_FUNCTIONS src_unpack
