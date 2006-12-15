# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit toolchain-funcs

MISC_VER=18
SHELL_VER=74.1

DESCRIPTION="Miscelaneous commands used on Darwin/Mac OS X systems"
HOMEPAGE="http://www.opensource.apple.com/"
SRC_URI="http://www.opensource.apple.com/darwinsource/tarballs/other/misc_cmds-${MISC_VER}.tar.gz
	http://www.opensource.apple.com/darwinsource/tarballs/other/shell_cmds-${SHELL_VER}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~ppc-macos ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND=""

S=${WORKDIR}

src_compile() {
	local TS=${S}/misc_cmds-${MISC_VER}
	# tsort is provided by coreutils
	for t in cal leave lock units ; do
		cd "${TS}/${t}"
		echo "in ${TS}/${t}:"
		echo "$(tc-getCC) -o ${t} ${t}.c"
		$(tc-getCC) -o ${t} ${t}.c || die "failed to compile $t"
	done
	cd "${TS}/calendar"
	echo "in ${TS}/calendar:"
	echo "$(tc-getCC) -o calendar calendar.c io.c day.c ostern.c paskha.c"
	$(tc-getCC) -o calendar calendar.c io.c day.c ostern.c paskha.c \
		|| die "failed to compile calendar"

	TS=${S}/shell_cmds-${SHELL_VER}
	# only pick those tools not provided by coreutils, findutils
	for t in \
		alias apply getopt hostname jot kill killall \
		lastcomm renice script shlock time whereis;
	do
		echo "in ${TS}/${t}:"
		echo "$(tc-getCC) -o ${t} ${t}.c"
		cd "${TS}/${t}"
		$(tc-getCC) -o ${t} ${t}.c || die "failed to compile $t"
	done
	cd "${TS}/su"
	echo "in ${TS}/su:"
	echo "$(tc-getCC) -lpam -o su su.c"
	$(tc-getCC) -lpam -o su su.c || die "failed to compile su"
	cd "${TS}/w"
	echo "in ${TS}/w:"
	echo "$(tc-getCC) -DSUCKAGE -lresolv -o w w.c pr_time.c proc_compare.c"
	$(tc-getCC) -DSUCKAGE -lresolv -o w w.c pr_time.c proc_compare.c \
		|| die "failed to compile w"
}

src_install() {
	mkdir -p "${ED}"/bin
	mkdir -p "${ED}"/usr/bin

	local TS=${S}/misc_cmds-${MISC_VER}
	for t in cal leave lock units calendar ; do
		cp "${TS}/${t}/${t}" "${ED}"/usr/bin/
		doman "${TS}/${t}/${t}.1"
	done

	TS=${S}/shell_cmds-${SHELL_VER}
	for t in \
		alias apply getopt jot killall lastcomm \
		renice script shlock su time w whereis;
	do
		cp "${TS}/${t}/${t}" "${ED}"/usr/bin/
		doman "${TS}/${t}/${t}.1"
	done
	cp "${TS}/w/w" "${ED}"/usr/bin/uptime
	doman "${TS}/w/uptime.1"
	for t in hostname kill; do
		cp "${TS}/${t}/${t}" "${ED}"/bin/
		doman "${TS}/${t}/${t}.1"
	done
}
