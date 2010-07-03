#!/usr/bin/env bash
# Copyright 2006-2010 Gentoo Foundation; Distributed under the GPL v2
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
			elif [[ x$(type -t ftp) == "xfile" ]] ; then
				FETCH_COMMAND="ftp"
			elif [[ x$(type -t curl) == "xfile" ]] ; then
				einfo "WARNING: curl doesn't fail when downloading fails, please check its output carefully!"
				FETCH_COMMAND="curl -L -O"
			elif [[ x$(type -t fetch) == "xfile" ]] ; then
				FETCH_COMMAND="fetch"
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
	local ldflags_make_defaults="LDFLAGS=\"-L${ROOT}/usr/lib -R${ROOT}/usr/lib -L${ROOT}/lib -R${ROOT}/lib\""
	local cppflags_make_defaults="CPPFLAGS=\"-I${ROOT}/usr/include\""
	local extra_make_globals=""
	einfo "setting up some guessed defaults"
	case ${CHOST} in
		powerpc-apple-darwin7)
			profile="${PORTDIR}/profiles/prefix/darwin/macos/10.3"
			ldflags_make_defaults="LDFLAGS=\"-Wl,-search_paths_first -L${ROOT}/usr/lib -L${ROOT}/lib\""
			;;
		powerpc-apple-darwin8)
			profile="${PORTDIR}/profiles/prefix/darwin/macos/10.4/ppc"
			ldflags_make_defaults="LDFLAGS=\"-Wl,-search_paths_first -L${ROOT}/usr/lib -L${ROOT}/lib\""
			;;
		powerpc64-apple-darwin8)
			profile="${PORTDIR}/profiles/prefix/darwin/macos/10.4/ppc64"
			ldflags_make_defaults="LDFLAGS=\"-Wl,-search_paths_first -L${ROOT}/usr/lib -L${ROOT}/lib\""
			extra_make_globals="
CC='gcc -m64'
CXX='g++ -m64'
HOSTCC='gcc -m64'
"
			;;
		i*86-apple-darwin8)
			profile="${PORTDIR}/profiles/prefix/darwin/macos/10.4/x86"
			ldflags_make_defaults="LDFLAGS=\"-Wl,-search_paths_first -L${ROOT}/usr/lib -L${ROOT}/lib\""
			;;
		powerpc-apple-darwin9)
			profile="${PORTDIR}/profiles/prefix/darwin/macos/10.5/ppc"
			ldflags_make_defaults="LDFLAGS=\"-Wl,-search_paths_first -L${ROOT}/usr/lib -L${ROOT}/lib\""
			;;
		i*86-apple-darwin9)
			profile="${PORTDIR}/profiles/prefix/darwin/macos/10.5/x86"
			ldflags_make_defaults="LDFLAGS=\"-Wl,-search_paths_first -L${ROOT}/usr/lib -L${ROOT}/lib\""
			;;
		x86_64-apple-darwin9)
			profile="${PORTDIR}/profiles/prefix/darwin/macos/10.5/x64"
			ldflags_make_defaults="LDFLAGS=\"-Wl,-search_paths_first -L${ROOT}/usr/lib -L${ROOT}/lib\""
			extra_make_globals="
CC='gcc -m64'
CXX='g++ -m64'
HOSTCC='gcc -m64'
"
			;;
		i*86-apple-darwin10)
			profile="${PORTDIR}/profiles/prefix/darwin/macos/10.6/x86"
			ldflags_make_defaults="LDFLAGS=\"-Wl,-search_paths_first -L${ROOT}/usr/lib -L${ROOT}/lib\""
			extra_make_globals="
CC='gcc -m32'
CXX='g++ -m32'
HOSTCC='gcc -m32'
"
			;;
		x86_64-apple-darwin10)
			profile="${PORTDIR}/profiles/prefix/darwin/macos/10.6/x64"
			ldflags_make_defaults="LDFLAGS=\"-Wl,-search_paths_first -L${ROOT}/usr/lib -L${ROOT}/lib\""
			extra_make_globals="
CC='gcc -m64'
CXX='g++ -m64'
HOSTCC='gcc -m64'
"
			;;
		i*86-pc-linux-gnu)
			profile="${PORTDIR}/profiles/prefix/linux/x86"
			;;
		x86_64-pc-linux-gnu)
			profile="${PORTDIR}/profiles/prefix/linux/amd64"
			;;
		ia64-pc-linux-gnu)
			profile="${PORTDIR}/profiles/prefix/linux/ia64"
			;;
		powerpc-unknown-linux-gnu)
			profile="${PORTDIR}/profiles/prefix/linux/ppc"
			;;
		armv7l-pc-linux-gnu)
			profile="${PORTDIR}/profiles/prefix/linux/arm"
			;;
		sparc-sun-solaris2.9)
			profile="${PORTDIR}/profiles/prefix/sunos/solaris/5.9/sparc"
			;;
		sparcv9-sun-solaris2.9)
			profile="${PORTDIR}/profiles/prefix/sunos/solaris/5.9/sparc64"
			ldflags_make_defaults="LDFLAGS=\"-L${ROOT}/usr/lib -R${ROOT}/usr/lib -L${ROOT}/lib -R${ROOT}/lib -L/usr/sfw/lib/64 -R/usr/sfw/lib/64\""
			extra_make_globals="
CC='gcc -m64'
CXX='g++ -m64'
HOSTCC='gcc -m64'
"
			;;
		i386-pc-solaris2.10)
			profile="${PORTDIR}/profiles/prefix/sunos/solaris/5.10/x86"
			;;
		x86_64-pc-solaris2.10)
			profile="${PORTDIR}/profiles/prefix/sunos/solaris/5.10/x64"
			ldflags_make_defaults="LDFLAGS=\"-L${ROOT}/usr/lib -R${ROOT}/usr/lib -L${ROOT}/lib -R${ROOT}/lib -L/usr/sfw/lib/64 -R/usr/sfw/lib/64\""
			extra_make_globals="
CC='gcc -m64'
CXX='g++ -m64'
HOSTCC='gcc -m64'
"
			;;
		sparc-sun-solaris2.10)
			profile="${PORTDIR}/profiles/prefix/sunos/solaris/5.10/sparc"
			;;
		sparcv9-sun-solaris2.10)
			profile="${PORTDIR}/profiles/prefix/sunos/solaris/5.10/sparc64"
			ldflags_make_defaults="LDFLAGS=\"-L${ROOT}/usr/lib -R${ROOT}/usr/lib -L${ROOT}/lib -R${ROOT}/lib -L/usr/sfw/lib/64 -R/usr/sfw/lib/64\""
			extra_make_globals="
CC='gcc -m64'
CXX='g++ -m64'
HOSTCC='gcc -m64'
"
			;;
		i386-pc-solaris2.11)
			profile="${PORTDIR}/profiles/prefix/sunos/solaris/5.11/x86"
			;;
		x86_64-pc-solaris2.11)
			profile="${PORTDIR}/profiles/prefix/sunos/solaris/5.11/x64"
			ldflags_make_defaults="LDFLAGS=\"-L${ROOT}/usr/lib -R${ROOT}/usr/lib -L${ROOT}/lib -R${ROOT}/lib -L/usr/sfw/lib/64 -R/usr/sfw/lib/64\""
			extra_make_globals="
CC='gcc -m64'
CXX='g++ -m64'
HOSTCC='gcc -m64'
"
			;;
		sparc-sun-solaris2.11)
			profile="${PORTDIR}/profiles/prefix/sunos/solaris/5.11/sparc"
			;;
		sparcv9-sun-solaris2.11)
			profile="${PORTDIR}/profiles/prefix/sunos/solaris/5.11/sparc64"
			ldflags_make_defaults="LDFLAGS=\"-L${ROOT}/usr/lib -R${ROOT}/usr/lib -L${ROOT}/lib -R${ROOT}/lib -L/usr/sfw/lib/64 -R/usr/sfw/lib/64\""
			extra_make_globals="
CC='gcc -m64'
CXX='g++ -m64'
HOSTCC='gcc -m64'
"
			;;
		powerpc-ibm-aix*)
			profile="${PORTDIR}/profiles/prefix/aix/${CHOST#powerpc-ibm-aix}/ppc"
			;;
		mips-sgi-irix*)
			profile="${PORTDIR}/profiles/prefix/irix/${CHOST#mips-sgi-irix}/mips"
			;;
		i586-pc-interix*)
			profile="${PORTDIR}/profiles/prefix/windows/interix/${CHOST#i586-pc-interix}/x86"
			;;
		i586-pc-winnt*)
			profile="${PORTDIR}/profiles/prefix/windows/winnt/${CHOST#i586-pc-winnt}/x86"
			;;
		hppa64*-hp-hpux11*)
			profile="${PORTDIR}/profiles/prefix/hpux/B.11${CHOST#hppa*-hpux11}/hppa64"
			;;
		hppa2.0*-hp-hpux11*)
			profile="${PORTDIR}/profiles/prefix/hpux/B.11${CHOST#hppa*-hpux11}/hppa2.0"
			ldflags_make_defaults="LDFLAGS=\"-L${ROOT}/usr/lib -R${ROOT}/usr/lib -L/usr/local/lib -R/usr/local/lib\""
			;;
		ia64-hp-hpux11*)
			profile="${PORTDIR}/profiles/prefix/hpux/B.11${CHOST#ia64-hp-hpux11}/ia64"
			;;
		i386-pc-freebsd*)
			profile="${PORTDIR}/profiles/prefix/bsd/freebsd/${CHOST#i386-pc-freebsd}/x86"
			;;
		x86_64-pc-freebsd*)
			profile="${PORTDIR}/profiles/prefix/bsd/freebsd/${CHOST#x86_64-pc-freebsd}/x64"
			;;
		i386-pc-netbsd*)
			profile="${PORTDIR}/profiles/prefix/bsd/netbsd/${CHOST#i386-pc-netbsdelf}/x86"
			;;
		powerpc-unknown-openbsd*)
			profile="${PORTDIR}/profiles/prefix/bsd/openbsd/${CHOST#powerpc-unknown-openbsd}/ppc"
			;;
		i386-pc-openbsd*)
			profile="${PORTDIR}/profiles/prefix/bsd/openbsd/${CHOST#i386-pc-openbsd}/x86"
			;;
		x86_64-pc-openbsd*)
			profile="${PORTDIR}/profiles/prefix/bsd/openbsd/${CHOST#x86_64-pc-openbsd}/x64"
			;;
		*)	
			einfo "You need to set up a make.profile symlink to a"
			einfo "profile in ${PORTDIR} for your CHOST ${CHOST}"
			;;
	esac
	if [[ -n ${profile} && ! -e ${ROOT}/etc/make.profile ]] ; then
		ln -s "${profile}" "${ROOT}"/etc/make.profile
		einfo "Your profile is set to ${profile}."
		echo "${extra_make_globals}" >> "${ROOT}"/etc/make.globals
		# this is darn ugly, but we can't use the make.globals hack,
		# since the profiles overwrite CFLAGS/LDFLAGS in numerous cases
		echo "${cppflags_make_defaults}" >> "${profile}"/make.defaults
		echo "${ldflags_make_defaults}" >> "${profile}"/make.defaults
		# The default profiles (and IUSE defaults) introduce circular deps. By
		# shoving this USE line into make.defaults, we can ensure that the
		# end-user always avoids circular deps while bootstrapping and it gets
		# wiped after a --sync. Also simplifies bootstrapping instructions.
		echo "USE=\"-berkdb -fortran -gdbm -nls -pcre -ssl -python bootstrap\"" >>\
			"${profile}"/make.defaults
		einfo "Your make.globals is prepared for your current bootstrap"
	fi
}

do_tree() {
	for x in etc {,usr/}{,s}bin var/tmp var/lib/portage var/log/portage var/db;
	do
		[[ -d ${ROOT}/${x} ]] || mkdir -p "${ROOT}/${x}"
	done
	if [[ ! -e ${ROOT}/usr/portage/.unpacked ]]; then
		cd "${ROOT}"/usr
		efetch "$1/$2"
		# beware: fetch creates DISTDIR!!!
		mv "${DISTDIR}" distfiles
		rm -Rf portage
		einfo "Unpacking, this may take awhile"
		bzip2 -dc distfiles/$2 | $TAR -xf - || exit 1
		mv distfiles portage/
		touch portage/.unpacked
	fi
}

bootstrap_tree() {
	local PV="20100509"
	do_tree http://prefix.gentooexperimental.org/distfiles prefix-overlay-${PV}.tar.bz2
}

bootstrap_latest_tree() {
	do_tree "${SNAPSHOT_URL}" portage-latest.tar.bz2
}

# Added for darkside, don't remove. A static starting point it needed.
bootstrap_tree_arm() {
	do_tree http://prefix.gentooexperimental.org/~darkside/distfiles/prefix/ prefix-overlay-20100114.tar.bz2
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
	PV="2.2.00.15842"
	A=prefix-portage-${PV}.tar.bz2
	einfo "Bootstrapping ${A%-*}"
		
	efetch ${DISTFILES_URL}/${A}

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
		--mandir="${ROOT}/automatically-removed" \
		--with-extra-path="${ROOT}/tmp/bin:${ROOT}/tmp/usr/bin:/bin:/usr/bin:${PATH}"
	$MAKE ${MAKEOPTS} || exit 1

 	einfo "Installing ${A%-*}"
	$MAKE install || exit 1

	bootstrap_setup

	cd "${ROOT}"
	rm -Rf ${ptmp} >& /dev/null

	# Some people will skip the tree() step and hence var/log is not created 
	# As such, portage complains..
	[[ ! -d $ROOT/var/log ]] && mkdir ${ROOT}/var/log
	
	# during bootstrap_portage(), man pages are not compressed. This is
	# problematic once you have a working prefix. So, remove them now.
	rm -rf "${ROOT}/automatically-removed"	

	# in Prefix the sed wrapper is deadly, so kill it
	rm -f "${ROOT}"/usr/lib/portage/bin/ebuild-helpers/sed

	einfo "${A%-*} successfully bootstrapped"
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

	efetch ${GENTOO_MIRROR}/${GCC_A}

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
	einfo "Unpacking ${GCC_A}"
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
	einfo "${GCC_A%-*} successfully bootstrapped"
}

bootstrap_gnu() {
	local PN PV A S
	PN=$1
	PV=$2
	A=${PN}-${PV}.tar.gz
	[[ $PN == "gzip" ]] && A=${PN}-${PV}.tar
	einfo "Bootstrapping ${A%-*}"

	URL=${3-${GENTOO_MIRROR}/${A}}
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
	if [[ ${A%-*} == "grep" ]] ; then
		# Solaris, AIX and OSX don't like it when --disable-nls is set,
		# so just don't set it at all.
		# Solaris 11 has a messed up prce installation.  We don't need
		# it anyway, so just disable it
		myconf="${myconf} --disable-perl-regexp"
		# Except interix really needs it for grep.
		[[ $CHOST == *interix* ]] && myconf="${myconf} --disable-nls"
	else
		# AIX doesn't like --disable-nls in general
		[[ $CHOST == *-aix* ]] || myconf="${myconf} --disable-nls"
	fi

	# NetBSD has strange openssl headers, which make wget fail.
	[[ $CHOST == *-netbsd* ]] && myconf="${myconf} --disable-ntlm"

	# Darwin9 in particular doesn't compile when using system readline,
	# but we don't need any groovy input at all, so just disable it
	[[ ${A%-*} == "bash" ]] && myconf="${myconf} --disable-readline"

	# Don't do ACL stuff on Darwin, especially Darwin9 will make
	# coreutils completely useless (install failing on everything)
	[[ ${A%-*} == "coreutils" ]] && myconf="${myconf} --disable-acl"

	if [[ ${A%-*} == "coreutils" && ${CHOST} == *-interix* ]] ; then
		# Interix doesn't have filesystem listing stuff, but that means all
		# other utilities but df aren't useless at all, so don't die
		sed -i -e '/^if test -z "$ac_list_mounted_fs"; then$/c\if test 1 = 0; then' configure

		# try to make id() not poll the entire domain before returning
		export CFLAGS="${CFLAGS} -Dgetgrgid=getgrgid_nomembers -Dgetgrent=getgrent_nomembers -Dgetgrnam=getgrnam_nomembers"

		# Fix a compilation error due to a missing definition
		sed -i -e '/^#include "fcntl-safer.h"$/a\#define ESTALE -1' lib/savewd.c
	fi

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
	if [[ ${CHOST} == *-interix* ]] ; then
		PV=2.6.4
		A=python-${PV}-interix.tar.bz2
	else
		PV=2.6.4
		A=python-${PV}-patched.tar.bz2
	fi
	einfo "Bootstrapping ${A%-*}"

	# don't really want to put this on the mirror, since they are
	# non-vanilla sources, bit specific for us
	efetch ${DISTFILES_URL}/${A}

	einfo "Unpacking ${A%%-*}"
	export S="${PORTAGE_TMPDIR}/python-${PV}"
	rm -rf "${S}"
	mkdir -p "${S}"
	cd "${S}"
	bzip2 -dc "${DISTDIR}"/${A} | $TAR -xf - || exit 1
	S="${S}"/Python-${PV}
	cd "${S}"

	local myconf=""

	case $CHOST in
		*-*-aix*)
			# Python stubbornly insists on using cc_r to compile.  We
			# know better, so force it to listen to us
			myconf="${myconf} --with-gcc=yes"
		;;
		*-openbsd*)
			CFLAGS="${CFLAGS} -D_BSD_SOURCE=1"
		;;
	esac

	# if the user has a $HOME/.pydistutils.cfg file, the python
	# installation is going to be screwed up, as reported by users, so
	# just make sure Python won't find it
	export HOME="${S}"

	export PYTHON_DISABLE_MODULES="readline pyexpat dbm gdbm bsddb _curses _curses_panel _tkinter _elementtree _locale"
	export PYTHON_DISABLE_SSL=1
	export OPT="${CFLAGS}"

	einfo "Compiling ${A%-*}"
	econf \
		--disable-toolbox-glue \
		--disable-ipv6 \
		--with-cxx=no \
		--disable-shared \
		${myconf}
	$MAKE ${MAKEOPTS} || exit 1

	einfo "Installing ${A%-*}"
	$MAKE -k install || echo "??? Python failed to install *sigh* continuing anyway"
	cd "${ROOT}"/usr/bin
	ln -sf python${PV%.*} python

	einfo "${A%-*} bootstrapped"
}

bootstrap_sed() {
	bootstrap_gnu sed 4.1.4
}

bootstrap_findutils3() {
	bootstrap_gnu findutils 4.2.33
}

bootstrap_findutils() {
	# distfile with included patches for IRIX and Interix
	bootstrap_gnu findutils 4.4.0 \
		"http://dev.gentoo.org/~grobian/distfiles/findutils-4.4.0-patched.tar.gz"
}

bootstrap_wget() {
	bootstrap_gnu wget 1.10.2
}

bootstrap_grep() {
	bootstrap_gnu grep 2.5.1a
}

bootstrap_grep4() {
	bootstrap_gnu grep 2.5.4
}

bootstrap_coreutils() {
	bootstrap_gnu coreutils 5.94
}

bootstrap_coreutils6() {
	bootstrap_gnu coreutils 6.11
}

bootstrap_coreutils8() {
	bootstrap_gnu coreutils 8.2
}

bootstrap_tar15() {
	bootstrap_gnu tar 1.15.1
}

bootstrap_tar() {
	bootstrap_gnu tar 1.19
}

bootstrap_tar22() {
	bootstrap_gnu tar 1.22
}

bootstrap_make() {
	bootstrap_gnu make 3.81
}

bootstrap_patch() {
	bootstrap_gnu patch 2.5.4
}

bootstrap_patch9() {
	bootstrap_gnu patch 2.5.9
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
	# distfile with included patches to make portage happy
	bootstrap_gnu bash 3.2 \
		"${GENTOO_MIRROR}/bash-3.2-patched.tar.gz"
}

bootstrap_bison() {
	bootstrap_gnu bison 2.4
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

	efetch ${GENTOO_MIRROR}/${A}

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

# Try to guess the CHOST if not set.  We currently only support guessing
# on a very sloppy base.
if [[ -z ${CHOST} ]]; then
	if [[ x$(type -t uname) == "xfile" ]]; then
		case `uname -s` in
			Linux)
				case `uname -m` in
					ppc*)
						CHOST="`uname -m | sed -e 's/^ppc/powerpc/'`-unknown-linux-gnu"
						;;
					powerpc*)
						CHOST="`uname -m`-unknown-linux-gnu"
						;;
					*)
						CHOST="`uname -m`-pc-linux-gnu"
						;;
				esac
				;;
			Darwin)
				rev="`uname -r | cut -d'.' -f 1`"
				CHOST="`uname -p`-apple-darwin$rev"
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
					amd64)
						CHOST="x86_64-pc-freebsd`uname -r | sed 's|-.*$||'`"
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
	*-*-linux-gnu)
		MAKE=make
	;;
	*-apple-darwin*)
		MAKE=make
	;;
	*-*-solaris*)
		if type -P gmake > /dev/null ; then
			MAKE=gmake
		else
			MAKE=make
		fi
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
	*)
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

case $ROOT in
	chost.guess)
		# undocumented feature that sort of is our own config.guess, if
		# CHOST was unset, it now contains the guessed CHOST
		echo "$CHOST"
		exit 0
	;;
	/*) ;;
	*)
		echo "Your path offset needs to be absolute!" 1>&2
		exit 1
	;;
esac

CXXFLAGS="${CXXFLAGS:-${CFLAGS}}"
PORTDIR=${ROOT}/usr/portage
DISTDIR=${PORTDIR}/distfiles
PORTAGE_TMPDIR=${ROOT}/var/tmp
DISTFILES_URL="http://dev.gentoo.org/~grobian/distfiles"
SNAPSHOT_URL="http://prefix.gentooexperimental.org/snapshots"
GNU_URL=${GNU_URL:="http://ftp.gnu.org/gnu"}
GENTOO_MIRROR=${GENTOO_MIRROR:="http://distfiles.gentoo.org/distfiles"}
GCC_APPLE_URL="http://www.opensource.apple.com/darwinsource/tarballs/other"

export MAKE


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
