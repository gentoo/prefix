# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-biology/clustalw/clustalw-1.83-r1.ebuild,v 1.8 2006/01/04 23:37:30 ribosome Exp $

EAPI="prefix"

inherit toolchain-funcs

DESCRIPTION="General purpose multiple alignment program for DNA and proteins"
HOMEPAGE="http://www.embl-heidelberg.de/~seqanal/"
SRC_URI="ftp://ftp.ebi.ac.uk/pub/software/unix/clustalw/${PN}${PV}.UNIX.tar.gz"

LICENSE="clustalw"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

S="${WORKDIR}"/${PN}${PV}

src_unpack(){
	unpack ${A}
	cd "${S}"
	sed -i -e "s/CC	= cc/CC	= $(tc-getCC)/" \
		-e "s/CFLAGS  = -c -O/CFLAGS  = -c ${CFLAGS}/" \
		-e "s/LFLAGS	= -O -lm/LFLAGS	= -lm ${CFLAGS}/" makefile || die
	sed -i -e "s%clustalw_help%/usr/share/doc/${PF}/clustalw_help%" clustalw.c || die
}

src_compile() {
	emake || die
}

src_install() {
	dobin clustalw || die
	dodoc README clustalv.doc clustalw.doc clustalw.ms
	insinto /usr/share/doc/${PF}
	doins clustalw_help
}
