# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/games-ut2k4mod.eclass,v 1.9 2006/09/28 21:32:12 wolf31o2 Exp $

inherit games


EXPORT_FUNCTIONS pkg_nofetch src_unpack src_install pkg_postinst

DESCRIPTION="UT2004 - ${MOD_DESC}"

SLOT="0"
KEYWORDS="-* x86 amd64"
IUSE=""

DEPEND="app-arch/tar
	app-arch/bzip2"

RDEPEND="sys-libs/glibc"
PDEPEND=">=games-fps/ut2004-3339"

S=${WORKDIR}
dir=${GAMES_PREFIX_OPT}/ut2004
Ddir=${D}/${dir}

check_dvd() {
	# The following is a nasty mess to determine if we are installing from
	# a DVD or from multiple CDs.  Anyone feel free to submit patches to this
	# to bugs.gentoo.org as I know it is a very ugly hack.
	USE_DVD=
	USE_ECE_DVD=
	if [ -n "${CD_ROOT}" ]
	then
		[ -d "${CD_ROOT}/CD1" ] && USE_DVD=1
		[ -d "${CD_ROOT}/CD7" ] && USE_ECE_DVD=1
	else
		local mline=""
		for mline in `mount | egrep -e '(iso|cdrom)' | awk '{print $3}'`
		do
			[ -d "${mline}/CD1" ] && USE_DVD=1
			[ -d "${mline}/CD7" ] && USE_ECE_DVD=1
		done
	fi
}

games-ut2k4mod_pkg_nofetch() {
	einfo "Please download ${A} and put it into ${DISTDIR}"
	einfo "http://liflg.org/?catid=6&gameid=17"
}

games-ut2k4mod_src_unpack() {
	[ -z "${MOD_TBZ2}" ] && die "what are we supposed to unpack ?"
	[ -z "${MOD_NAME}" ] && die "what is the name of this ut2k4mod ?"

	for src_uri in ${A}
	do
		URI_SUFFIX="${src_uri##*.}"
		case ${URI_SUFFIX##*.} in
			run|bin)
				# We have a Makeself archive, use unpack_makeself
				unpack_makeself ${src_uri}
				# Since this is a Makeself archive, it has a lot of useless
				# files (for us), so we delete them.
				rm -rf setup.data setup.sh uninstall
				;;
			bz2|gz|Z|z|ZIP|zip)
				# We have a normal tarball/zip file, use unpack
				unpack ${src_uri}
				;;
		esac
	done

	mkdir ${S}/unpack
	for tarball in ${MOD_TBZ2}
	do
		if [ -e "${tarball}_${PV}-english.tar.bz2" ]
		then
			tar xjf ${tarball}_${PV}-english.tar.bz2 -C ${S}/unpack \
				|| die "uncompressing tarball"
		elif [ -e "${tarball}_${PV}.tar.bz2" ]
		then
			tar xjf ${tarball}_${PV}.tar.bz2 -C ${S}/unpack \
				|| die "uncompressing tarball"
		else [ -e "${tarball}.tar.bz2" ]
			tar xjf ${tarball}.tar.bz2 -C ${S}/unpack \
				|| die "uncompressing tarball"
		fi
	done
}

games-ut2k4mod_src_install() {
	dodir ${dir}
	cp -r ${S}/unpack/* ${Ddir}

	for readme in README*
	do
		dodoc ${readme} || die "dodoc failed"
	done
	if [ -n "${MOD_BINS}" ]
	then
		exeinto ${dir}
		doexe bin/${MOD_BINS} || die "doexe failed"
		games_make_wrapper ${MOD_BINS} ./${MOD_BINS} ${dir}
		make_desktop_entry ${MOD_BINS} "UT2004 - ${MOD_NAME}" ${MOD_ICON}
	fi

	[ -e ${MOD_ICON} ] && doicon ${MOD_ICON}

	prepgamesdirs
}

games-ut2k4mod_pkg_postinst() {
	if [ -n "${MOD_BINS}" ]
	then
		einfo "To play this mod run:"
		einfo " ${MOD_BINS}"
	fi

	games_pkg_postinst
}
