#!/usr/bin/env bash

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
		--prefix=${ROOT}/usr \
		--host=${CHOST} \
		--mandir=${ROOT}/usr/share/man \
		--infodir=${ROOT}/usr/share/info \
		--datadir=${ROOT}/usr/share \
		--sysconfdir=${ROOT}/etc \
		--localstatedir=${ROOT}/var/lib \
		"$@" || exit 1
}

fetch() {
	if [ ! -e "${DISTDIR}"/${1##*/} ] ; then
		if [ -z ${FETCH_COMMAND} ] ; then
			# Try to find a download manager, we only deal with wget and curl
			if [ x$(type -t wget) == "xfile" ];
			then
				FETCH_COMMAND="wget"
			elif [ x$(type -t curl) == "xfile" ];
			then
				FETCH_COMMAND="curl -O"
			else
				eerror "no suitable download manager found (need wget or curl)"
				eerror "could not download ${1##*/}"
				exit 1
			fi
		fi

		mkdir -p "${DISTDIR}" >& /dev/null
		einfo "Fetching ${1##*/}"
		pushd `pwd` > /dev/null
		cd "${DISTDIR}"
		${FETCH_COMMAND} "$1"
		popd > /dev/null
	fi
}

# template
# bootstrap_() {
# 	PV=
# 	A=
# 	einfo "Bootstrapping ${A%-*}"

# 	fetch ${A}

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
# 	$MAKE || exit 1

# 	einfo "Installing ${A%-*}"
# 	$MAKE install || exit 1

# 	einfo "${A%-*} succesfully bootstrapped"
# }

setup_portage() {
	local profile=""
	local keywords=""
	einfo "setting up some guessed defaults"
	case ${CHOST} in
		powerpc-*-darwin8)
			profile="${PORTDIR}/profiles/default-darwin/macos/10.4/ppc"
			keywords="~ppc-macos ppc-macos"
			;;
		powerpc-*-darwin7)
			profile="${PORTDIR}/profiles/default-darwin/macos/10.3"
			keywords="~ppc-macos ppc-macos"
			;;
		i*86-*-darwin8)
			profile="${PORTDIR}/profiles/default-darwin/macos/10.4/x86"
			keywords="~x86-macos x86-macos"
			;;
		i*86-pc-linux-gnu)
			profile="${PORTDIR}/profiles/default-linux/x86/2005.1"
			keywords="~x86 x86"
			;;
		x64_86-pc-linux-gnu)
			profile="${PORTDIR}/profiles/default-linux/amd64/2005.1/no-multilib"
			keywords="~amd64 amd64"
			;;
		ia64-pc-linux-gnu)
			profile="${PORTDIR}/profiles/default-linux/ia64/2006.0"
			keywords="~ia64 ia64"
			;;
		i386-sun-solaris2.10)
			profile="${PORTDIR}/profiles/default-sunos/solaris/5.10/x86"
			keywords="~x86-solaris x86-solaris"
			;;
		sparc-sun-solaris2.10)
			profile="${PORTDIR}/profiles/default-sunos/solaris/5.10/sparc"
			keywords="~sparc-solaris sparc-solaris"
			;;
		*)	
			einfo "You might need to set up a make.profile symlink to a profile in ${PORTDIR}"
			;;
	esac
	if [ ! -z "${profile}" -a ! -e "${ROOT}"/etc/make.profile ];
	then
		ln -s "${profile}" "${ROOT}"/etc/make.profile
		einfo "Your profile is set to ${profile}."
		einfo "If your system supports multilib, then this is a no-multilib profile."
	fi
	
	[ -e "${ROOT}"/etc/make.conf ] && return
	
	if [ ! -z "${keywords}" ];
	then
		echo "ACCEPT_KEYWORDS=\"${keywords}\"" >> "${ROOT}"/etc/make.conf
		einfo "Your ACCEPT_KEYWORDS is set to ${keywords}"
	fi

	einfo "Setting up sync uri"
	echo 'SYNC="svn+http://overlays.gentoo.org/svn/proj/alt/trunk/prefix-overlay"' >> ${ROOT}/etc/make.conf
}

bootstrap_tree() {
	PV="20070102"
	for x in etc usr/{,s}bin var/tmp var/lib/portage var/log/portage var/db;
	do
		[ -d "${ROOT}/${x}" ] || mkdir -p "${ROOT}/${x}"
	done
	if [ ! -e ${ROOT}/usr/portage/.unpacked ]; then
		cd ${ROOT}/usr
		fetch "${PORTAGE_URL}/prefix-overlay-${PV}.tar.bz2"
		bzip2 -dc ${DISTDIR}/prefix-overlay-${PV}.tar.bz2 | $TAR -xf - || exit 1
		# beware: fetch creates DISTDIR!!!
		mv portage/distfiles prefix-overlay/
		rm -Rf portage
		mv prefix-overlay portage
		touch portage/.unpacked
	fi
}

bootstrap_portage() {
	# don't use "latest" here, as I want to have the bootstrap script to
	# use a portage in a known "state"
	PV=2.1.20.5447
	A=prefix-portage-${PV}.tar.bz2
	einfo "Bootstrapping ${A%-*}"
		
	fetch ${PORTAGE_URL}/${A}

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
		--with-user=`id -un` \
		--with-group=`id -gn` \
		--with-wheelgid=`id -g` \
		--with-rootuser=`id -un` \
		--with-default-path="${ROOT}/tmp/bin:${ROOT}/tmp/usr/bin:/bin:/usr/bin"
	$MAKE || exit 1

 	einfo "Installing ${A%-*}"
	$MAKE install || exit 1

	einfo "making a symlink for sed in ${ROOT}/usr/bin"
	( cd ${ROOT}/usr/bin && ln -s ../../bin/sed )

	setup_portage

	rm -Rf ${ptmp} >& /dev/null
	einfo "${A%-*} succesfully bootstrapped"
}

bootstrap_odcctools() {
	PV=20060413
	A=odcctools-${PV}.tar.bz2

	fetch http://www.opendarwin.org/downloads/${A}
	
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
	$MAKE || exit 1

	$MAKE install || exit 1

	rm -Rf ${S}
}

prep_gcc-apple() {

	GCC_PV=5341
	GCC_A="gcc-${GCC_PV}.tar.gz"
	TAROPTS="-zxf"

	fetch ${GCC_APPLE_URL}/${GCC_A}

}

prep_gcc-fsf() {

	GCC_PV=4.1.1
	GCC_A=gcc-${GCC_PV}.tar.bz2	
	TAROPTS="-jxf"

	fetch ${GNU_URL}/gcc/gcc-${GCC_PV}/${GCC_A}

}

bootstrap_gcc() {

	case ${CHOST} in
		*-*-darwin*)
			prep_gcc-apple
			;;
		*-sun-solaris*)
			prep_gcc-fsf
			GCC_EXTRA_OPTS="--disable-multilib --with-gnu-ld"
			;;
		*)	
			prep_gcc-fsf
			;;
	esac

	GCC_LANG="c,c++"

	export S="${PORTAGE_TMPDIR}/gcc-${GCC_PV}"
	rm -rf ${S}
	mkdir -p ${S}
	cd ${S}
	$TAR ${TAROPTS} ${DISTDIR}/${GCC_A} || exit 1

	rm -rf ${S}/build
	mkdir -p ${S}/build
	cd ${S}/build

	gcc_config_opts="--prefix=${ROOT}/usr \
				--host=${CHOST} \
				--mandir=${ROOT}/usr/share/man \
				--infodir=${ROOT}/usr/share/info \
				--datadir=${ROOT}/usr/share \
				--disable-checking \
				--disable-werror \
				--disable-nls \
				--with-system-zlib \
				--enable-languages=${GCC_LANG}
				${GCC_EXTRA_OPTS}"


	${S}/gcc-${GCC_PV}/configure \
		${gcc_config_opts} \
		|| exit 1
	$MAKE ${MAKEOPTS} bootstrap-lean || exit 1

	$MAKE install || exit 1

	rm -Rf ${S}
}

bootstrap_gnu() {
	local PN PV A S
	PN=$1
	PV=$2
	A=${PN}-${PV}.tar.gz
	einfo "Bootstrapping ${A%-*}"

	fetch ${GNU_URL}/${PN}/${A}

	einfo "Unpacking ${A%-*}"
	S="${PORTAGE_TMPDIR}/${PN}-${PV}"
	rm -rf ${S}
	mkdir -p ${S}
	cd ${S}
	gzip -dc ${DISTDIR}/${A} | $TAR -xf - || exit 1
	S=${S}/${PN}-${PV}
	cd ${S}

	einfo "Compiling ${A%-*}"
	econf \
		--disable-nls
	$MAKE || exit 1

	einfo "Installing ${A%-*}"
	$MAKE install || exit 1

	rm -Rf ${S}
	einfo "${A%-*} succesfully bootstrapped"
}

bootstrap_python() {
	PV=2.4.2
	A=Python-${PV}.tar.bz2
	einfo "Bootstrapping ${A%-*}"

	fetch http://www.python.org/ftp/python/${PV%_*}/${A}

	einfo "Unpacking ${A%-*}"
	export S="${PORTAGE_TMPDIR}/python-${PV}"
	rm -rf ${S}
	mkdir -p ${S}
	cd ${S}
	bzip2 -dc ${DISTDIR}/${A} | $TAR -xf - || exit 1
	S=${S}/Python-${PV}
	cd ${S}

	export PYTHON_DISABLE_MODULES="readline pyexpat dbm gdbm bsddb _curses _curses_panel _tkinter"
	export PYTHON_DISABLE_SSL=1
	export OPT="${CFLAGS}"

	case $CHOST in
		*-sun-solaris*)
			# Solaris manpage says we need -lrt for fdatasync and
			# sem_wait & friends, Python apparently doesn't know
			export LDFLAGS="-lrt -laio -lmd5"
		;;
	esac

	einfo "Compiling ${A%-*}"
	econf \
		--disable-toolbox-glue \
		--enable-unicode=ucs4 \
		--with-fpectl \
		--disable-ipv6 \
		--with-threads \
		--with-cxx=no \
		--disable-shared
	$MAKE ${MAKEOPTS} || exit 1

	einfo "Installing ${A%-*}"
	$MAKE altinstall || exit 1
	cd ${ROOT}/usr/bin
	ln -sf python2.4 python

	einfo "${A%-*} succesfully bootstrapped"
}

bootstrap_sed() {
	bootstrap_gnu sed 4.1.4
}

bootstrap_findutils() {
	bootstrap_gnu findutils 4.2.27
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

bootstrap_tar() {
	bootstrap_gnu tar 1.15.1
}

bootstrap_patch() {
	bootstrap_gnu patch 2.5.9
}

bootstrap_binutils() {
	bootstrap_gnu binutils 2.17
}

## End Functions

## some vars

# We do not want stray $TMP, $TMPDIR or $TEMP settings
unset TMP TMPDIR TEMP

# Try to guess the CHOST if not set.  We currently only support Linux,
# Darwin and Solaris guessing on a very sloppy base.
if [ -z "${CHOST}" ];
then
	if [ x$(type -t uname) == "xfile" ];
	then
		case `uname -s` in
			Linux)
				CHOST="`uname -m`-pc-linux-gnu"
				MAKE=make
				;;
			Darwin)
				CHOST="`uname -p`-apple-darwin`/usr/sbin/sysctl kern.osrelease | cut -d'=' -f 2 | cut -d' ' -f 2- | cut -d'.' -f 1`"
				MAKE=make
				;;
			SunOS)
				CHOST="`uname -p`-sun-solaris`uname -r | sed 's|5|2|'`"
				# make needs to know it is gmake
				MAKE=gmake
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
MAKEOPTS="${MAKEOPTS:--j2}"
PORTDIR=${ROOT}/usr/portage
DISTDIR=${PORTDIR}/distfiles
PORTAGE_TMPDIR=${ROOT}/var/tmp
PORTAGE_URL="http://dev.gentoo.org/~grobian/distfiles"
GNU_URL="http://ftp.gnu.org/gnu"
GCC_APPLE_URL="http://darwinsource.opendarwin.org/tarballs/other"
GENTOO_URL="http://gentoo.osuosl.org"

export CFLAGS CXXFLAGS


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
