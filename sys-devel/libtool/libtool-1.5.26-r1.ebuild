# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/libtool/libtool-1.5.26-r1.ebuild,v 1.3 2013/03/12 14:23:05 vapier Exp $

EAPI="2"

inherit eutils multilib

DESCRIPTION="A shared library tool for developers"
HOMEPAGE="http://www.gnu.org/software/libtool/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="1.5"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

S=${WORKDIR}/${P}/libltdl

src_prepare() {
	epunt_cxx
}

src_configure() {
	econf --disable-static || die
}

src_install() {
	emake DESTDIR="${D}" install-exec || die
	# basically we just install ABI libs for old packages
	rm "${ED}"/usr/*/libltdl{.la,$(get_libname)} || die
}
