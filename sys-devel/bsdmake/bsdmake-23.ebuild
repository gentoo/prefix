# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit toolchain-funcs

DESCRIPTION="Apple's version of FreeBSD's make"
HOMEPAGE="http://www.opensource.apple.com/darwinsource"
SRC_URI="http://www.opensource.apple.com/darwinsource/tarballs/other/bsdmake-23.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~ppc-macos ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e "/^__FBSDID/d" *.c
}

src_compile() {
	local sources="arch.c buf.c cond.c dir.c for.c hash.c hash_tables.c \
		job.c lst.c main.c make.c parse.c proc.c shell.c str.c suff.c \
		targ.c util.c var.c"

	$(tc-getCC) \
		-DDEFSHELLNAME='"sh"' \
		-DPATH_DEFSYSPATH='"'"${EPREFIX}"'/usr/share/mk"' \
		-DPATH_DEFSHELLDIR='"'"${EPREFIX}"'/bin"' \
		-I. -o bsdmake ${sources} || die
}

src_install() {
	insinto /usr/bin
	doins bsdmake
	fperms 755 /usr/bin/bsdmake
	mv make.1 bsdmake.1
	doman bsdmake.1
	dodir /usr/share/mk
	cp -a mk/* "${ED}"/usr/share/mk/
}
