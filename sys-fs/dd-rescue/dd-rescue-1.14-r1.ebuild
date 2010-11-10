# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/dd-rescue/dd-rescue-1.14-r1.ebuild,v 1.1 2010/10/17 14:28:41 chainsaw Exp $

EAPI=3

inherit base

MY_PN=${PN/-/_}
MY_P=${MY_PN}-${PV}
DESCRIPTION="similar to dd but can copy from source with errors"
HOMEPAGE="http://www.garloff.de/kurt/linux/ddrescue/"
SRC_URI="http://www.garloff.de/kurt/linux/ddrescue/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="static"

RDEPEND=""
DEPEND=""

S=${WORKDIR}/${MY_PN}
PATCHES=( "${FILESDIR}/${P}-ldflags.patch" )

src_compile() {
	use static && append-flags -static
	emake RPM_OPT_FLAGS="${CFLAGS}" || die "emake failed"
}

src_install() {
	emake DESTDIR="${ED}" INSTALLFLAGS="" INSTASROOT="-o ${PORTAGE_INST_UID:-$(id -un)} -g ${PORTAGE_INST_GID:-$(id -gn)}" install || die "make install failed"
	dodoc README.dd_rescue
}
