# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/pep/pep-2.8.ebuild,v 1.9 2006/12/04 21:26:54 eroyf Exp $

EAPI="prefix"

inherit eutils flag-o-matic

DESCRIPTION="Pep is a general purpose filter and file cleaning program"
HOMEPAGE="http://folk.uio.no/gisle/enjoy/pep.html"
SRC_URI="http://folk.uio.no/gisle/enjoy/${PN}${PV//./}.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~mips-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="app-arch/unzip
	virtual/libc"
RDEPEND="virtual/libc"

S=${WORKDIR}

src_unpack() {
	unpack ${A}
	# pep does not come with autconf so here's a patch to configure
	# Makefile with the correct path
	epatch ${FILESDIR}/${P}-gentoo.patch || die "epatch failed"
	# Darwin lacks stricmp
	[[ ${CHOST} == *-darwin* ]] && \
		sed -i -e '/^OBJS/s/^\(.*\)$/\1 bdmg.o/' Makefile
}

src_compile() {
	[[ ${CHOST} == *-darwin* ]] && \
		append-flags "-DDIRCHAR=\\'/\\'" -DSTRICMP
	# make man page too
	make Doc/pep.1 || die "make man page failed"
	emake || die "emake failed"
}

src_install() {
	dobin pep || die
	doman Doc/pep.1

	insinto /usr/share/pep
	doins Filters/*

	dodoc aareadme.txt file_id.diz
}
