# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/asfrecorder/asfrecorder-1.1.ebuild,v 1.13 2007/05/08 17:10:16 grobian Exp $

EAPI="prefix"

inherit toolchain-funcs

MY_PN="${PN/asfr/ASFR}"
DESCRIPTION="ASFRecorder - Download Windows Media Streaming files"
HOMEPAGE="http://sourceforge.net/projects/asfrecorder/"
SRC_URI="mirror://sourceforge/${PN}/${MY_PN}.zip"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~ppc-macos ~x86"
IUSE=""

DEPEND="app-arch/unzip"

S=${WORKDIR}/${MY_PN}

src_compile() {
	# There is a Makefile, but it only works for Cygwin, so we
	# only compile this single program.
	cd ${S}/source
	$(tc-getCC) -o asfrecorder ${CFLAGS} asfrecorder.c || die "Build failed"
}

src_install () {
	# Again, no makefiles, so just take what we want.
	dobin ${S}/source/asfrecorder
	dodoc ${S}/README.TXT
}
