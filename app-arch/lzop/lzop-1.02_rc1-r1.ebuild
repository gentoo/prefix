# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/lzop/lzop-1.02_rc1-r1.ebuild,v 1.4 2007/01/17 17:35:11 grobian Exp $

EAPI="prefix"

inherit versionator

MY_P=${P/_/}

DESCRIPTION="Utility for fast (even real-time) compression/decompression"
HOMEPAGE="http://www.oberhumer.com/opensource/lzop/"
SRC_URI="http://www.oberhumer.com/opensource/lzop/download/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

DEPEND=">=dev-libs/lzo-2"
S=${WORKDIR}/${MY_P}


src_test() {
	einfo "compressing config.status to test"
	src/lzop config.status || die 'compression failed'
	ls -la config.status{,.lzo}
	src/lzop -t config.status.lzo || die 'lzo test failed'
	src/lzop -dc config.status.lzo | diff config.status - || die 'decompression generated differences from original'
}

src_install() {
	make install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog NEWS README THANKS
	dodoc doc/lzop.{txt,ps}
	dohtml doc/*.html
}
