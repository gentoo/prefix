# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cssc/cssc-1.2.0.ebuild,v 1.1 2010/01/11 05:41:36 jer Exp $

EAPI="2"

DESCRIPTION="CSSC is the GNU Project's replacement for SCCS"
SRC_URI="mirror://gnu/${PN}/CSSC-${PV}.tar.gz"
HOMEPAGE="http://cssc.sourceforge.net/"
SLOT="0"
LICENSE="GPL-2 LGPL-2"
S=${WORKDIR}/CSSC-${PV}
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND=""

src_prepare() {
	# The large test takes a long time
	sed -i tests/Makefile.* \
		-e 's|\([[:space:]]\)test-large |\1|g' || die "sed failed"
}

src_configure() { econf --enable-binary; }
src_compile() { emake all; }

src_install () {
	emake DESTDIR="${D}" install || die
	dodoc README NEWS ChangeLog AUTHORS
}
