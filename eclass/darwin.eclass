# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-projects/darwin/overlay/eclass/darwin.eclass,v 1.2 2005/08/10 17:28:09 kito Exp $
#
# darwin.eclass Kito <kito@gentoo.org>
#
# Without the very hardwork of kvv@opendarwin.org none of this would be known...
#
# Voodoo to setup the build environment for most darwin projects.
#
# The build and install phases both happen in src_install to take
# advantage of the XBS build system...for better or for worse
#

ECLASS=darwin
INHERITED="$INHERITED $ECLASS"
EXPORT_FUNCTIONS pkg_setup src_compile src_install

HOMEPAGE="http://www.opendarwin.org/ http://www.gentoo.org/" 
LICENSE="APSL-2"
IUSE=""
SLOT="0"

DEPEND="sys-apps/bootstrap_cmds
	sys-devel/cctools
	sys-devel/gcc-apple"

##
# xnu common functions
#=================================================================

xnu_unpack() {
	
	unpack ${A}
	
	cd ${WORKDIR}/xnu-${PV}/makedefs
	sed -i \
		-e 's:^export RELPATH = .*:export RELPATH = /usr/bin/relpath:' \
		-e 's:^SEG_HACK = .*:SEG_HACK = /usr/bin/seg_hack:' \
		-e 's:^DECOMMENT = .*:DECOMMENT = /usr/bin/decomment:' MakeInc.cmd
	
	cd ${WORKDIR}/xnu-${PV}/libsa/conf
	sed -i -e 's|/usr/local/lib|/usr/lib|g' Makefile.template

	cd ${WORKDIR}/xnu-${PV}/config
	sed -i -e 's|/usr/local/bin|/usr/bin|g' Makefile

}

##
# common functions
#=================================================================

darwinmake() {
	local BUILDTARGET=
	mkdir -p ${WORKDIR}/build/obj ${WORKDIR}/build/sym

	if [[ `ls -d *.pbproj *.xcode *.xcodeproj 2> /dev/null | wc -l` -gt 0 ]] ; then
		use debug && BUILDSTYLE="Development" || BUILDSTYLE="Deployment"
		BUILDCOMMAND="xcodebuild"  
		BUILDOPTS="-configuration ${BUILDSTYLE}"	
	else
		BUILDCOMMAND="make"
	fi

	if [[ ${1} ==  "compile" ]] ; then
		unset ${BUILDTARGET}
	elif [[ ! ${1} ]] ; then
		BUILDTARGET="install"
	else
		#if [[ "${BUILDCOMMAND}" -eq "make" ]] ; then
		#	if [[ -e "${S}/GNUMakefile" ]] ; then
		#		BUILDTARGET="-f GNUMakefile"
		#	elif [[ -e "${S}/GNUmakefile" ]] ; then
                #               BUILDTARGET="-f GNUmakefile"
		#	else
		#		die "Couldn't find a valid Makefile!!"
		#	fi
		BUILDTARGET="${1}"
	fi

	if use x86 && ! use ppc ; then
		RC_ARCHS="i386"
                RCARCHS="RC_i386=YES"
		RC_CFLAGS="${RC_CFLAGS} -arch i386"
        elif use ppc && ! use x86; then
                RC_ARCHS="ppc"
		RCARCHS="RC_ppc=YES"
		RC_CFLAGS="${RC_CFLAGS} -arch ppc"
        elif use ppc64 && ! use x86 ; then
                RC_ARCHS="ppc ppc64"
		RCARCHS="RC_ppc=YES"
		RC_CFLAGS="${RC_CFLAGS} -arch ppc -arch ppc64"
        elif use x86 && use ppc ; then
		RC_ARCHS="ppc i386"
		RCARCHS="RC_ppc=YES RC_i386=YES"
		RC_CFLAGS="${RC_CFLAGS} -arch ppc -arch i386"
	fi

	ewarn ${RC_ARCHS} ${RCARCHS} ${RC_CFLAGS}
	einfo `pwd`
	einfo "${BUILDCOMMAND} ${BUILDTARGET} ${BUILDOPTS}"
	
	"${BUILDCOMMAND}" "${BUILDTARGET}" \
	"SRCROOT=${S}" \
        "OBJROOT=${WORKDIR}/build/obj" \
        "SYMROOT=${WORKDIR}/build/sym" \
	"DSTROOT=${D}" \
        "RC_ProjectBuildVersion=1" \
        "INSTALLED_PRODUCT_ASIDES=YES" \
        "MACOSX_DEPLOYMENT_TARGET=10.4" \
        "NEXT_ROOT=" \
        "RC_ARCHS=${RC_ARCHS}" \
        "RC_CFLAGS=${RC_CFLAGS} -no-cpp-precomp" \
        "RC_JASPER=YES" \
        "RC_NONARCH_CFLAGS=${RC_CFLAGS} -no-cpp-precomp" \
        "RC_OS=macos" \
        "RC_RELEASE=Tiger" \
        "RC_XBS=YES" \
        "SEPARATE_STRIP=YES" \
        "UNAME_RELEASE=8.0" \
        "UNAME_SYSNAME=Darwin" \
	"${RCARCHS}" \
	|| die "${BUILDCOMMAND} ${BUILDTARGET} ${BUILDOPTS} failed"
}

doditto() {
	if [ ${#} -lt 2 ] ; then
		einfo "${0}: at least two  arguments needed"
		die
	fi
	if [ -x /usr/bin/ditto ]; then
		/usr/bin/ditto --rsrc -vV "${1}" "${2}" || die "/usr/bin/ditto --rsrc -vV ${1} ${2} failed"
	else
		tar c -C "${1}" . | tar xf - -C "${2}" || die "tar c -C $1 . | tar xf - -C $2"
	fi
}

puntusrlocal() {

	for GNUMAKEFILE in `find . -name Makefile -print` ; do
		sed -i -e 's:/usr/local:/usr:' ${GNUMAKEFILE} \
			|| die "sed ${GNUMAKEFILE} failed"      
	done
}

pkginstall() {
	for x in "$@" ; do
		einfo "searching for ${x}"
		find /Volumes ${PKGDIR} /Users -type d -name ${x}.pkg -maxdepth 3 2>/dev/null | grep -v Receipts | \
		while read PKG; do
			if [ -f "${PKG}/Contents/Archive.pax.gz" ]; then
				einfo "Using ${PKG}..."
				#doditto ${PKG} ${S}/${PKG} || die "doditto ${PKG} ${S}/${PKG} failed."
				dodir /
				cd ${D}
				gunzip -c "${PKG}/Contents/Archive.pax.gz" | pax -r \
					|| die "Failed to extract ${PKG}/Contents/Archive.pax.gz"
			else
				die "$x does not appear to be a valid .pkg"
			fi
		done
	done
}

darwin_pkg_setup() {
	mkdir -p ${WORKDIR}/build/obj ${WORKDIR}/build/sym
}

darwin_src_compile() {
	:
}

darwin_src_install() {
	cd ${S}
	darwinmake || die "darwinmake failed"
}

