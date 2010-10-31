# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/libtool/libtool-1.5.26-r1.ebuild,v 1.2 2010/09/26 21:23:14 ssuominen Exp $

EAPI="2"

inherit multilib

DESCRIPTION="A shared library tool for developers"
HOMEPAGE="http://www.gnu.org/software/libtool/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="1.5"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

S=${WORKDIR}/${P}/libltdl

src_configure() {
	econf --disable-static || die
}

src_install() {
	emake DESTDIR="${D}" install-exec || die
	# basically we just install ABI libs for old packages
	rm "${ED}"/usr/*/libltdl{.la,$(get_libname)} || die
}
