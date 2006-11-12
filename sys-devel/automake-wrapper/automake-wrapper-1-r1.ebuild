# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/automake-wrapper/automake-wrapper-1-r1.ebuild,v 1.6 2006/11/03 18:35:40 grobian Exp $

EAPI="prefix"

inherit multilib

DESCRIPTION="wrapper for automake to manage multiple automake versions"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""

S=${WORKDIR}

src_install() {
	exeinto /usr/$(get_libdir)/misc
	newexe "${FILESDIR}"/am-wrapper-${PV}.sh am-wrapper.sh || die

	keepdir /usr/share/aclocal

	dodir /usr/bin
	local x=
	for x in aclocal automake ; do
		dosym ../$(get_libdir)/misc/am-wrapper.sh /usr/bin/${x}
	done
}
