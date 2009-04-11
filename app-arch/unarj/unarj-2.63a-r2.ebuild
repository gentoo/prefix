# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/unarj/unarj-2.63a-r2.ebuild,v 1.15 2007/07/14 14:51:34 drizzt Exp $

inherit eutils

DESCRIPTION="Utility for opening arj archives"
HOMEPAGE="http://ibiblio.org/pub/Linux/utils/compress/"
SRC_URI="http://ibiblio.org/pub/Linux/utils/compress/${P}.tar.gz"

LICENSE="arj"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris"
IUSE=""

src_unpack() {
	unpack ${A}
	cd ${S}
	sed -i "/^CFLAGS/s:-O2:${CFLAGS}:" Makefile
	epatch ${FILESDIR}/unarj-2.65-CAN-2004-0947.patch
	epatch ${FILESDIR}/${P}-sanitation.patch
	 sed -i -e 's@strip unarj@@' Makefile
}

src_install() {
	dobin unarj || die 'dobin failed'
	dodoc unarj.txt technote.txt readme.txt || die 'dodoc failed'
}
