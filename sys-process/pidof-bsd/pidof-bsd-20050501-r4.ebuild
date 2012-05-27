# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-process/pidof-bsd/pidof-bsd-20050501-r4.ebuild,v 1.1 2012/05/24 13:10:40 ryao Exp $

inherit base toolchain-funcs

DESCRIPTION="pidof(1) utility for *BSD"
HOMEPAGE="http://people.freebsd.org/~novel/pidof.html"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~ppc-macos ~x64-macos ~x86-macos"
IUSE=""

DEPEND="!prefix? ( sys-freebsd/freebsd-mk-defs )"
RDEPEND="!sys-process/psmisc"

S="${WORKDIR}/pidof"

PATCHES=( "${FILESDIR}/${P}-gfbsd.patch"
	"${FILESDIR}/${P}-firstarg.patch"
	"${FILESDIR}/${P}-pname.patch" )

[[ ${CHOST} == *-darwin* ]] && \
	PATCHES=( ${PATCHES[@]} ${FILESDIR}/${P}-darwin.patch )
[[ ${CHOST} == *-netbsd* ]] && \
	PATCHES=( ${PATCHES[@]} ${FILESDIR}/${P}-netbsd.patch )

src_compile() {
	local libs=""
	[[ ${CHOST} == *-*bsd* ]] && libs="-lkvm"
	$(tc-getCC) -o pidof pidof.c ${libs} || die
}

src_install() {
	into /
	dobin pidof
}
