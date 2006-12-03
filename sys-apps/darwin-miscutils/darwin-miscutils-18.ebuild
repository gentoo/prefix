# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit toolchain-funcs

DESCRIPTION="Miscelaneous commands used on Darwin/Mac OS X systems"
HOMEPAGE="http://www.apple.com/macosx/"
SRC_URI="http://www.opensource.apple.com/darwinsource/tarballs/other/misc_cmds-${PV}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~ppc-macos ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND=""

S=${WORKDIR}/misc_cmds-${PV}

src_compile() {
	# tsort is provided by coreutils
	for t in cal leave lock units ; do
		cd "${S}/${t}"
		$(tc-getCC) -o ${t} ${t}.c || die "failed to compile $t"
	done
	cd "${S}/calendar"
	$(tc-getCC) -o calendar calendar.c io.c day.c ostern.c paskha.c \
		|| die "failed to compile calendar"
}

src_install() {
	mkdir -p "${ED}"/usr/bin
	for t in cal leave lock units calendar ; do
		cp "${S}/${t}/${t}" "${ED}"/usr/bin/
		doman "${S}/${t}/${t}.1"
	done
}
