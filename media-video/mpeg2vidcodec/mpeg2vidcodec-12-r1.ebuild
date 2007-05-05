# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/mpeg2vidcodec/mpeg2vidcodec-12-r1.ebuild,v 1.29 2007/02/11 11:24:47 vapier Exp $

EAPI="prefix"

MY_P="${PN}_v${PV}"
DESCRIPTION="MPEG Library"
HOMEPAGE="http://www.mpeg.org/"
SRC_URI="ftp://ftp.mpeg.org/pub/mpeg/mssg/${MY_P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~x86"
IUSE=""

RDEPEND=""
DEPEND=">=sys-apps/sed-4"

S=${WORKDIR}/mpeg2

src_unpack() {
	unpack ${A}
	sed -i \
		-e "s:-O2:${CFLAGS}:" \
		"${S}"/Makefile \
		|| die "sed Makefile failed"
}

src_install() {
	dobin src/mpeg2dec/mpeg2decode src/mpeg2enc/mpeg2encode \
		|| die "dobin failed"
	dodoc README doc/*
}
