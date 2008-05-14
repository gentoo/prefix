#!/usr/bin/env bash
# Copyright Gentoo Foundation 2006-2007
# $Id$

trap 'exit 1' TERM KILL INT QUIT ABRT

# some basic output functions
eerror() { echo "!!! $*" 1>&2; }
einfo() { echo "* $*"; }

# prefer gtar over tar
[[ x$(type -t gtar) == "xfile" ]] \
	&& TAR="gtar" \
	|| TAR="tar"

## Functions Start Here

econf() {
	./configure \
		--host=${CHOST} \
		--prefix="${ROOT}"/usr \
		--mandir="${ROOT}"/usr/share/man \
		--infodir="${ROOT}"/usr/share/info \
		--datadir="${ROOT}"/usr/share \
		--sysconfdir="${ROOT}"/etc \
		--localstatedir="${ROOT}"/var/lib \
		--build=${CHOST} \
		"$@" || exit 1
}

efetch() {
	if [[ ! -e ${DISTDIR}/${1##*/} ]] ; then
		if [[ -z ${FETCH_COMMAND} ]] ; then
			# Try to find a download manager, we only deal with wget,
			# curl, FreeBSD's fetch and ftp.
			if [[ x$(type -t wget) == "xfile" ]] ; then
				FETCH_COMMAND="wget"
			elif [[ x$(type -t curl) == "xfile" ]] ; then
				FETCH_COMMAND="curl -O"
			elif [[ x$(type -t fetch) == "xfile" ]] ; then
				FETCH_COMMAND="fetch"
			elif [[ x$(type -t ftp) == "xfile" ]] ; then
				FETCH_COMMAND="ftp"
			else
				eerror "no suitable download manager found (need wget, curl, fetch or ftp)"
				eerror "could not download ${1##*/}"
				exit 1
			fi
		fi

		mkdir -p "${DISTDIR}" >& /dev/null
		einfo "Fetching ${1##*/}"
		pushd "${DISTDIR}" > /dev/null
		${FETCH_COMMAND} "$1"
		if [[ ! -f ${1##*/} ]] ; then
			eerror "downloading ${1} failed!"
			exit 1
		fi
		popd > /dev/null
	fi
}

# template
# bootstrap_() {
# 	PV=
# 	A=
# 	einfo "Bootstrapping ${A%-*}"

# 	efetch ${A}

# 	einfo "Unpacking ${A%-*}"
# 	export S="${PORTAGE_TMPDIR}/${PN}"
# 	rm -rf ${S}
# 	mkdir -p ${S}
# 	cd ${S}
# 	$TAR -zxf ${DISTDIR}/${A} || exit 1
# 	S=${S}/${PN}-${PV}
# 	cd ${S}

# 	einfo "Compiling ${A%-*}"
# 	econf
# 	$MAKE ${MAKEOPTS} || exit 1

# 	einfo "Installing ${A%-*}"
# 	$MAKE install || exit 1

# 	einfo "${A%-*} successfully bootstrapped"
# }

bootstrap_setup() {
	local profile=""
	local keywords=""
	einfo "setting up some guessed defaults"
	case ${CHOST} in
		powerpc-apple-darwin7)
			profile="${PORTDIR}/profiles/default-prefix/darwin/macos/10.3"
			;;
		powerpc-apple-darwin8)
			profile="${PORTDIR}/profiles/default-prefix/darwin/macos/10.4/ppc"
			;;
		powerpc64-apple-darwin8)
			profile="${PORTDIR}/profiles/default-prefix/darwin/macos/10.4/ppc64"
			;;
		i*86-apple-darwin8)
			profile="${PORTDIR}/profiles/default-prefix/darwin/macos/10.4/x86"
			;;
		powerpc-apple-darwin9)
			profile="${PORTDIR}/profiles/default-prefix/darwin/macos/10.5/ppc"
			;;
		i*86-apple-darwin9)
			profile="${PORTDIR}/profiles/default-prefix/darwin/macos/10.5/x86"
			;;
		x86_64-apple-darwin9)
			profile="${PORTDIR}/profiles/default-prefix/darwin/macos/10.5/x64"
			;;
		i*86-pc-linux-gnu)
			profile="${PORTDIR}/profiles/default-prefix/linux/x86"
			;;
		x86_64-pc-linux-gnu)
			profile="${PORTDIR}/profiles/default-prefix/linux/amd64"
			;;
		ia64-pc-linux-gnu)
			profile="${PORTDIR}/profiles/default-prefix/linux/ia64"
			;;
		sparc-sun-solaris2.9)
			profile="${PORTDIR}/profiles/default-prefix/sunos/solaris/5.9/sparc"
			;;
		i386-pc-solaris2.10)
			profile="${PORTDIR}/profiles/default-prefix/sunos/solaris/5.10/x86"
			;;
		x86_64-pc-solaris2.10)
			profile="${PORTDIR}/profiles/default-prefix/sunos/solaris/5.10/x64"
			;;
		sparc-sun-solaris2.10)
			profile="${PORTDIR}/profiles/default-prefix/sunos/solaris/5.10/sparc"
			;;
		sparcv9-sun-solaris2.10)
			profile="${PORTDIR}/profiles/default-prefix/sunos/solaris/5.10/sparc64"
			;;
		powerpc-ibm-aix*)
			profile="${PORTDIR}/profiles/default-prefix/aix/${CHOST#powerpc-ibm-aix}/ppc"
			;;
		mips-sgi-irix*)
			profile="${PORTDIR}/profiles/default-prefix/irix/${CHOST#mips-sgi-irix}/mips"
			;;
		i586-pc-interix*)
			profile="${PORTDIR}/profiles/default-prefix/windows/interix/${CHOST#i586-pc-interix}/x86"
			;;
		i586-pc-winnt*)
			profile="${PORTDIR}/profiles/default-prefix/windows/winnt/${CHOST#i586-pc-winnt}/x86"
			;;
		hppa*-hp-hpux11*)
			profile="${PORTDIR}/profiles/default-prefix/hpux/B.11${CHOST#hppa*-hpux11}/hppa"
			case "${CHOST}" in
			hppa2.0n*) profile="${profile}/hppa2.0/32" ;;
			hppa2.0w*) profile="${profile}/hppa2.0/64" ;;
			esac
			;;
		ia64-hp-hpux11*)
			profile="${PORTDIR}/profiles/default-prefix/hpux/B.11${CHOST#ia64-hp-hpux11}/ia64"
			;;
		i386-pc-freebsd*)
			profile="${PORTDIR}/profiles/default-prefix/bsd/freebsd/${CHOST#i386-pc-freebsd}/x86"
			;;
		i386-pc-netbsd*)
			profile="${PORTDIR}/profiles/default-prefix/bsd/netbsd/${CHOST#i386-pc-netbsdelf}/x86"
			;;
		powerpc-unknown-openbsd*)
			profile="${PORTDIR}/profiles/default-prefix/bsd/openbsd/${CHOST#powerpc-unknown-openbsd}/ppc"
			;;
		i386-pc-openbsd*)
			profile="${PORTDIR}/profiles/default-prefix/bsd/openbsd/${CHOST#i386-pc-openbsd}/x86"
			;;
		x86_64-pc-openbsd*)
			profile="${PORTDIR}/profiles/default-prefix/bsd/openbsd/${CHOST#x86_64-pc-openbsd}/x64"
			;;
		*)	
			einfo "You need to set up a make.profile symlink to a"
			einfo "profile in ${PORTDIR} for your CHOST ${CHOST}"
			;;
	esac
	if [[ -n ${profile} && ! -e ${ROOT}/etc/make.profile ]] ; then
		ln -s "${profile}" "${ROOT}"/etc/make.profile
		einfo "Your profile is set to ${profile}."
	fi
	
	[[ -e ${ROOT}/etc/make.conf ]] && return
	
	einfo "Setting up sync uri"
	echo 'SYNC="svn://overlays.gentoo.org/proj/alt/trunk/prefix-overlay"' >> ${ROOT}/etc/make.conf
}

bootstrap_tree() {
	local def="20080504"
	case ${CHOST} in
		powerpc-ibm-aix*)            PV="${def}" ;;
		i*86-apple-darwin8)          PV="${def}" ;;
		i*86-apple-darwin9)          PV="${def}" ;;
		powerpc-apple-darwin7)       PV="${def}" ;;
		powerpc-apple-darwin8)       PV="${def}" ;;
		powerpc-apple-darwin9)       PV="${def}" ;;
		powerpc64-apple-darwin8)     PV="${def}" ;;
		x86_64-apple-darwin9)        PV="${def}" ;;
		i386-pc-freebsd*)            PV="${def}" ;;
		hppa*-hp-hpux11*)            PV="${def}" ;;
		ia64-hp-hpux11*)             PV="${def}" ;;
		i586-pc-interix*)            PV="${def}" ;;
		i586-pc-winnt*)              PV="${def}" ;;
		mips-sgi-irix*)              PV="${def}" ;;
		i*86-pc-linux-gnu)           PV="${def}" ;;
		ia64-pc-linux-gnu)           PV="${def}" ;;
		x86_64-pc-linux-gnu)         PV="${def}" ;;
		i*86-pc-netbsdelf*)          PV="${def}" ;; 
		powerpc-unknown-openbsd*)    PV="${def}" ;;
		i*86-pc-openbsd*)            PV="${def}" ;;
		x86_64-pc-openbsd*)          PV="${def}" ;;
		i386-pc-solaris2.10)         PV="${def}" ;;
		sparc-sun-solaris2.10)       PV="${def}" ;;
		sparc-sun-solaris2.9)        PV="${def}" ;;
		sparcv9-sun-solaris2.10)     PV="${def}" ;;
		x86_64-pc-solaris2.10)       PV="${def}" ;;
		*)
			einfo "warning: no specific tree snapshot known for your system"
			PV="${def}"
		;;
	esac
	for x in etc usr/{,s}bin var/tmp var/lib/portage var/log/portage var/db;
	do
		[[ -d ${ROOT}/${x} ]] || mkdir -p "${ROOT}/${x}"
	done
	if [[ ${CHOST} == x86_64-pc-linux-gnu ]] ; then
		# this is our only (and last remaining) multilib system, we need
		# to be ahead of Portage to create usr/lib, otherwise baselayout
		# can't create the lib -> lib64 symlink, see bug #183874
		mkdir -p "${ROOT}"/usr/lib64
		( cd "${ROOT}"/usr && ln -s lib64 lib )
	fi
	if [ ! -e "${ROOT}"/usr/portage/.unpacked ]; then
		cd "${ROOT}"/usr
		efetch "${PORTAGE_URL}/prefix-overlay-${PV}.tar.bz2"
		bzip2 -dc "${DISTDIR}"/prefix-overlay-${PV}.tar.bz2 | $TAR -xf - || exit 1
		# beware: fetch creates DISTDIR!!!
		mv portage/distfiles distfiles
		rm -Rf portage
		mv prefix-overlay* portage
		mv distfiles portage/
		touch portage/.unpacked
	fi
}

bootstrap_startscript() {
	theshell=${SHELL##*/}
	if [[ ${theshell} == "sh" ]] ; then
		einfo "sh is a prehistoric shell not available in Gentoo, switching to bash instead."
		theshell="bash"
	fi
	einfo "Trying to emerge the shell you use, if necessary by running:"
	einfo "emerge -u ${theshell}"
	if ! emerge -u ${theshell} ; then
		eerror "Your shell is not available in portage, hence we cannot automate starting your prefix" > /dev/stderr
		exit -1
	fi
	einfo "Creating the Prefix start script (startprefix)"
	# currently I think right into the prefix is the best location, as
	# putting it in /bin or /usr/bin just hides it some more for the
	# user
	sed \
		-e "s|@GENTOO_PORTAGE_EPREFIX@|${ROOT}|g" \
		"${ROOT}"/usr/portage/scripts/startprefix.in \
		> "${ROOT}"/startprefix
	chmod 755 "${ROOT}"/startprefix
	einfo "To start Gentoo Prefix, run the script ${ROOT}/startprefix"
	einfo "You can copy this file to a more convenient place if you like."
}

bootstrap_portage() {
	# don't use "latest" here, as I want to have the bootstrap script to
	# use a portage in a known "state"
	PV="2.2.00.10181"
	A=prefix-portage-${PV}.tar.bz2
	einfo "Bootstrapping ${A%-*}"
		
	efetch ${PORTAGE_URL}/${A}

	einfo "Unpacking ${A%-*}"
	export S="${PORTAGE_TMPDIR}"/portage-${PV}
	ptmp=${S}
	rm -rf "${S}" >& /dev/null
	mkdir -p "${S}" >& /dev/null
	cd "${S}"
	bzip2 -dc "${DISTDIR}/${A}" | $TAR -xf - || exit 1
	S="${S}/prefix-portage-${PV}"
	cd "${S}"

	einfo "Compiling ${A%-*}"
	econf \
		--with-offset-prefix="${ROOT}" \
		--with-portage-user="`id -un`" \
		--with-portage-group="`id -gn`" \
		--with-eapi='"prefix"' \
		--with-default-path="${ROOT}/tmp/bin:${ROOT}/tmp/usr/bin:/bin:/usr/bin:${PATH}"
	$MAKE ${MAKEOPTS} || exit 1

 	einfo "Installing ${A%-*}"
	$MAKE install || exit 1

	einfo "making a symlink for sed in ${ROOT}/usr/bin"
	( cd ${ROOT}/usr/bin && ln -s ../../bin/sed )

	if [[ $MAKE != "make" ]] ; then
		einfo "making a symlink for $MAKE"
		( cd ${ROOT}/tmp/usr/bin && ln -s $(which $MAKE) make )
	fi

	bootstrap_setup

	cd "${ROOT}"
	rm -Rf ${ptmp} >& /dev/null
	einfo "${A%-*} successfully bootstrapped"
}

bootstrap_odcctools() {
	PV=20070412
	A=odcctools-${PV}.tar.bz2

	efetch http://dev.gentoo.org/~grobian/distfiles/${A}
	
	export S="${PORTAGE_TMPDIR}/odcctools-${PV}"
	rm -rf "${S}"
	mkdir -p "${S}"
	cd "${S}"
	bzip2 -dc "${DISTDIR}/${A}" | $TAR -xf - || exit 1

	rm -rf "${S}/build"
	mkdir -p "${S}/build"
	cd "${S}/build"

	"${S}"/odcctools-${PV}/configure \
		--prefix="${ROOT}"/usr \
		--mandir="${ROOT}"/usr/share/man \
		|| exit 1
	$MAKE ${MAKEOPTS} || exit 1

	$MAKE install || exit 1

	cd "${ROOT}"
	rm -Rf "${S}"
}

prep_gcc-apple() {

	GCC_PV=5341
	GCC_A="gcc-${GCC_PV}.tar.gz"
	TAROPTS="-zxf"

	efetch ${GCC_APPLE_URL}/${GCC_A}

}

prep_gcc-fsf() {

	GCC_PV=4.1.1
	GCC_A=gcc-${GCC_PV}.tar.bz2	
	TAROPTS="-jxf"

	efetch ${GNU_URL}/gcc/gcc-${GCC_PV}/${GCC_A}

}

bootstrap_gcc() {

	case ${CHOST} in
		*-*-darwin*)
			prep_gcc-apple
			;;
		*-*-solaris*)
			prep_gcc-fsf
			GCC_EXTRA_OPTS="--disable-multilib --with-gnu-ld"
			;;
		*)	
			prep_gcc-fsf
			;;
	esac

	GCC_LANG="c,c++"

	export S="${PORTAGE_TMPDIR}/gcc-${GCC_PV}"
	rm -rf "${S}"
	mkdir -p "${S}"
	cd "${S}"
	$TAR ${TAROPTS} "${DISTDIR}"/${GCC_A} || exit 1

	rm -rf "${S}"/build
	mkdir -p "${S}"/build
	cd "${S}"/build

	${S}/gcc-${GCC_PV}/configure \
		--prefix="${ROOT}"/usr \
		--mandir="${ROOT}"/usr/share/man \
		--infodir="${ROOT}"/usr/share/info \
		--datadir="${ROOT}"/usr/share \
		--disable-checking \
		--disable-werror \
		--disable-nls \
		--with-system-zlib \
		--enable-languages=${GCC_LANG} \
		${GCC_EXTRA_OPTS} \
		|| exit 1

	$MAKE ${MAKEOPTS} bootstrap-lean || exit 1

	$MAKE install || exit 1

	cd "${ROOT}"
	rm -Rf "${S}"
}

bootstrap_gnu() {
	local PN PV A S
	PN=$1
	PV=$2
	A=${PN}-${PV}.tar.gz
	[[ $PN == "gzip" ]] && A=${PN}-${PV}.tar
	einfo "Bootstrapping ${A%-*}"

	URL=${3-${GNU_URL}/${PN}/${A}}
	efetch ${URL}

	einfo "Unpacking ${A%-*}"
	S="${PORTAGE_TMPDIR}/${PN}-${PV}"
	rm -rf "${S}"
	mkdir -p "${S}"
	cd "${S}"
	if [[ $PN == "gzip" ]]; then
		$TAR -xf "${DISTDIR}"/${A} || exit 1
	else
		gzip -dc "${DISTDIR}"/${URL##*/} | $TAR -xf - || exit 1
	fi
	S="${S}"/${PN}-${PV}
	cd "${S}"

	local myconf=""
	# AIX doesn't like it when --disable-nls is set, OSX doesn't like it
	# when it's not.  Solaris and Linux build fine with --disable-nls.
	[[ $CHOST == *-aix* ]] || myconf="${myconf} --disable-nls"

	# NetBSD has strange openssl headers, which make wget fail.
	[[ $CHOST == *-netbsd* ]] && myconf="${myconf} --disable-ntlm"

	# Darwin9 in particular doesn't compile when using system readline,
	# but we don't need any groovy input at all, so just disable it
	[[ ${A%-*} == "bash" ]] && myconf="${myconf} --disable-readline"

	# Don't do ACL stuff on Darwin, especially Darwin9 will make
	# coreutils completely useless (install failing on everything)
	[[ ${A%-*} == "coreutils" ]] && myconf="${myconf} --disable-acl"

	# Interix doesn't have filesystem listing stuff, but that means all
	# other utilities but df aren't useless at all, so don't die
	[[ ${A%-*} == "coreutils" && ${CHOST} == *-interix* ]] && \
		sed -i -e '/^if test -z "$ac_list_mounted_fs"; then$/c\if test 1 = 0; then' configure
	# Fix a compilation error due to a missing definition
	[[ ${A%-*} == "coreutils" && ${CHOST} == *-interix* ]] && \
		sed -i -e '/^#include "fcntl-safer.h"$/a\#define ESTALE -1' lib/savewd.c

	einfo "Compiling ${A%-*}"
	econf ${myconf}
	$MAKE ${MAKEOPTS} || exit 1

	einfo "Installing ${A%-*}"
	$MAKE install || exit 1

	cd "${ROOT}"
	rm -Rf "${S}"
	einfo "${A%-*} successfully bootstrapped"
}

bootstrap_python() {
	PV=2.5.2
	A=Python-${PV}.tar.bz2
	einfo "Bootstrapping ${A%-*}"

	if [[ ${CHOST} == *-interix* ]] ; then
		A=python-${PV}-interix.tar.bz2
		efetch http://www.gentoo.org/~grobian/distfiles/${A}
	else
		efetch http://www.python.org/ftp/python/${PV%_*}/${A}
	fi

	einfo "Unpacking ${A%%-*}"
	export S="${PORTAGE_TMPDIR}/python-${PV}"
	rm -rf "${S}"
	mkdir -p "${S}"
	cd "${S}"
	bzip2 -dc "${DISTDIR}"/${A} | $TAR -xf - || exit 1
	S="${S}"/Python-${PV}
	cd "${S}"

	# fix OpenBSD detection
	sed -i -e 's/OpenBSD\/4.\[\[0\]\]/OpenBSD\/4.\[\[0123456789\]\]/' \
		configure 
	[[ ${CHOST} == *-openbsd* ]] && CFLAGS="${CFLAGS} -D_BSD_SOURCE=1"

	export PYTHON_DISABLE_MODULES="readline pyexpat dbm gdbm bsddb _curses _curses_panel _tkinter"
	export PYTHON_DISABLE_SSL=1
	export OPT="${CFLAGS}"

	local myconf=""

	case $CHOST in
		*-*-solaris*)
			# Solaris manpage says we need -lrt for fdatasync and
			# sem_wait & friends, Python apparently doesn't know
			export LDFLAGS="-lrt -laio -lmd5"
		;;
		*-*-aix*)
			# Python stubbornly insists on using cc_r to compile.  We
			# know better, so force it to listen to us
			myconf="${myconf} --with-gcc=yes"
		;;
	esac

	einfo "Compiling ${A%-*}"
	econf \
		--disable-toolbox-glue \
		--disable-ipv6 \
		--with-cxx=no \
		--disable-shared \
		${myconf}
	$MAKE ${MAKEOPTS} || exit 1

	einfo "Installing ${A%-*}"
	$MAKE -k altinstall || echo "??? Python failed to install *sigh* continuing anyway"
	cd "${ROOT}"/usr/bin
	ln -sf python2.5 python

	einfo "${A%-*} successfully bootstrapped"
}

bootstrap_sed() {
	bootstrap_gnu sed 4.1.4
}

bootstrap_findutils3() {
	bootstrap_gnu findutils 4.3.11
}

bootstrap_findutils() {
	# distfile with included patches for IRIX and Interix
	bootstrap_gnu findutils 4.4.0 \
		"http://www.gentoo.org/~grobian/distfiles/findutils-4.4.0-patched.tar.gz"
}

bootstrap_wget() {
	bootstrap_gnu wget 1.10.2
}

bootstrap_grep() {
	bootstrap_gnu grep 2.5.1a
}

bootstrap_coreutils() {
	bootstrap_gnu coreutils 5.94
}

bootstrap_coreutils6() {
	bootstrap_gnu coreutils 6.11
}

bootstrap_tar15() {
	bootstrap_gnu tar 1.15.1
}

bootstrap_tar() {
	bootstrap_gnu tar 1.19
}

bootstrap_patch() {
	bootstrap_gnu patch 2.5.4
}

bootstrap_make() {
	bootstrap_gnu make 3.81
}

bootstrap_patch9() {
	bootstrap_gnu patch 2.5.9 \
		"http://distfiles.gentoo.org/distfiles/patch-2.5.9.tar.gz"
}

bootstrap_gawk() {
	bootstrap_gnu gawk 3.1.5
}

bootstrap_binutils() {
	bootstrap_gnu binutils 2.17
}

bootstrap_texinfo() {
	bootstrap_gnu texinfo 4.8
}

bootstrap_bash() {
	bootstrap_gnu bash 3.2
}

bootstrap_gzip() {
	bootstrap_gnu gzip 1.3.12
}

bootstrap_bzip2() {
	local PN PV A S
	PN=bzip2
	PV=1.0.4
	A=${PN}-${PV}.tar.gz
	einfo "Bootstrapping ${A%-*}"

	efetch http://www.bzip.org/${PV}/${A}

	einfo "Unpacking ${A%-*}"
	S="${PORTAGE_TMPDIR}/${PN}-${PV}"
	rm -rf "${S}"
	mkdir -p "${S}"
	cd "${S}"
	gzip -dc "${DISTDIR}"/${A} | $TAR -xf - || exit 1
	S="${S}"/${PN}-${PV}
	cd "${S}"

	einfo "Compiling ${A%-*}"
	$MAKE || exit 1

	einfo "Installing ${A%-*}"
	$MAKE PREFIX="${ROOT}"/usr install || exit 1

	cd "${ROOT}"
	rm -Rf "${S}"
	einfo "${A%-*} successfully bootstrapped"
}

## End Functions

## some vars

# We do not want stray $TMP, $TMPDIR or $TEMP settings
unset TMP TMPDIR TEMP

# Try to guess the CHOST if not set.  We currently only support Linux,
# Darwin, Solaris and AIX guessing on a very sloppy base.
if [ -z "${CHOST}" ];
then
	if [ x$(type -t uname) == "xfile" ];
	then
		case `uname -s` in
			Linux)
				CHOST="`uname -m`-pc-linux-gnu"
				;;
			Darwin)
				CHOST="`uname -p`-apple-darwin`uname -r | cut -d'.' -f 1`"
				;;
			SunOS)
				case `uname -p` in
					i386)
						CHOST="i386-pc-solaris`uname -r | sed 's|5|2|'`"
					;;
					sparc)
						CHOST="sparc-sun-solaris`uname -r | sed 's|5|2|'`"
					;;
				esac
				;;
			AIX)
				# GNU coreutils uname sucks, it doesn't know what
				# processor it is using on AIX.  We mimick GNU CHOST
				# guessing here, instead of what IBM uses itself.
				CHOST="`/usr/bin/uname -p`-ibm-aix`oslevel`"
				;;
			IRIX|IRIX64)
				CHOST="mips-sgi-irix`uname -r`"
				;;
			Interix)
				case `uname -m` in
					x86) CHOST="i586-pc-interix`uname -r`" ;;
					*) eerror "Can't deal with interix `uname -m` (yet)"
					   exit 1
					;;
				esac
				;;
			HP-UX)
				case `uname -m` in
				ia64) HP_ARCH=ia64 ;;
				9000/[678][0-9][0-9])
					if [ ! -x /usr/bin/getconf ]; then
						eerror "Need /usr/bin/getconf to determine cpu"
						exit 1
					fi
					# from config.guess
					sc_cpu_version=`/usr/bin/getconf SC_CPU_VERSION 2>/dev/null`
					sc_kernel_bits=`/usr/bin/getconf SC_KERNEL_BITS 2>/dev/null`
					case "${sc_cpu_version}" in
					523) HP_ARCH="hppa1.0" ;; # CPU_PA_RISC1_0
					528) HP_ARCH="hppa1.1" ;; # CPU_PA_RISC1_1
					532)                      # CPU_PA_RISC2_0
						case "${sc_kernel_bits}" in
						32) HP_ARCH="hppa2.0n" ;;
						64) HP_ARCH="hppa2.0w" ;;
						'') HP_ARCH="hppa2.0" ;;   # HP-UX 10.20
						esac ;;
					esac
					;;
				esac
				uname_r=`uname -r`
				if [ -z "${HP_ARCH}" ]; then
					error "Cannot determine cpu/kernel type"
					exit ;
				fi
				CHOST="${HP_ARCH}-hp-hpux${uname_r#B.}"
				unset HP_ARCH uname_r
				;;
			FreeBSD)
				case `uname -p` in
					i386)
						CHOST="i386-pc-freebsd`uname -r | sed 's|-.*$||'`"
					;;
					*)
						eerror "Sorry, don't know about FreeBSD on `uname -p` yet"
						exit 1
					;;
				esac
				;;
			NetBSD)
				case `uname -p` in
					i386)
						CHOST="`uname -p`-pc-netbsdelf`uname -r`"
					;;
					*)
						eerror "Sorry, don't know about NetBSD on `uname -p` yet"
						exit 1
					;;
				esac
				;;
			OpenBSD)
				case `uname -m` in
					macppc)
						CHOST="powerpc-unknown-openbsd`uname -r`"
					;;
					i386)
						CHOST="i386-pc-openbsd`uname -r`"
					;;
					amd64)
						CHOST="x86_64-pc-openbsd`uname -r`"
					;;
					*)
						eerror "Sorry, don't know about OpenBSD on `uname -m` yet"
						exit 1
					;;
				esac
				;;
			*)
				eerror "Nothing known about platform `uname -s`."
				eerror "Please set CHOST appropriately for your system"
				eerror "and rerun $0"
				exit 1
				;;
		esac
	fi
fi

# Now based on the CHOST set some required variables.  Doing it here
# allows for user set CHOST still to result in the appropriate variables
# being set.
case ${CHOST} in
	*-pc-linux-gnu)
		MAKE=make
	;;
	*-apple-darwin*)
		MAKE=make
	;;
	*-*-solaris*)
		MAKE=gmake
	;;
	*-ibm-aix*)
		MAKE=make
	;;
	*-sgi-irix*)
		MAKE=gmake
	;;
	*-pc-interix*)
		MAKE=make
	;;
	*-hp-hpux*)
		MAKE=make
	;;
	*-*-freebsd*)
		MAKE=make
	;;
	*-*-openbsd*)
		MAKE=make
	;;
	*-*-netbsd*)
		MAKE=make
	;;
esac

# Just guessing a prefix is kind of scary.  Hence, to make it a bit less
# scary, we force the user to give the prefix location here.  This also
# makes the script a bit less dangerous as it will die when just ran to
# "see what happens".
if [ -z "$1" ];
then
	echo "usage: $0 <prefix-path> [action]"
	echo
	echo "You need to give the path offset for your Gentoo prefixed"
	echo "portage installation, e.g. $HOME/prefix."
	echo "The action to perform is optional and defaults to 'all'."
	echo "See the source of this script for which actions exist."
	echo
	echo "$0: insufficient number of arguments" 1>&2
	exit 1
fi

ROOT="$1"

CFLAGS="-O2 -pipe"
CXXFLAGS="${CFLAGS:--O2 -pipe}"
PORTDIR=${ROOT}/usr/portage
DISTDIR=${PORTDIR}/distfiles
PORTAGE_TMPDIR=${ROOT}/var/tmp
PORTAGE_URL="http://dev.gentoo.org/~grobian/distfiles"
GNU_URL="ftp://ftp.gnu.org/gnu"
GCC_APPLE_URL="http://www.opensource.apple.com/darwinsource/tarballs/other"
GENTOO_URL="http://gentoo.osuosl.org"

export CFLAGS CXXFLAGS MAKE


einfo "Bootstrapping Gentoo prefixed portage installation using"
einfo "host:   ${CHOST}"
einfo "prefix: ${ROOT}"

TODO=${2}
if [[ $(type -t bootstrap_${TODO}) != "function" ]];
then
	eerror "bootstrap target ${TODO} unknown"
	exit 1
fi

einfo "ready to bootstrap ${TODO}"
bootstrap_${TODO}
