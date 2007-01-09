# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/autoconf-wrapper/autoconf-wrapper-3.2-r2.ebuild,v 1.11 2006/12/29 22:10:55 vapier Exp $

EAPI="prefix"

inherit multilib

DESCRIPTION="wrapper for autoconf to manage multiple autoconf versions"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""

S=${WORKDIR}

src_install() {
	exeinto /usr/$(get_libdir)/misc
	newexe "${FILESDIR}"/ac-wrapper-${PV}.sh ac-wrapper.sh || die
	dosed '/^binary_new=/s:2.59:2.60:' /usr/$(get_libdir)/misc/ac-wrapper.sh
	dosed "1s|/bin/bash|${EPREFIX}/bin/bash|" /usr/$(get_libdir)/misc/ac-wrapper.sh

	dodir /usr/bin
	local x=
	for x in auto{conf,header,m4te,reconf,scan,update} ifnames ; do
		dosym ../$(get_libdir)/misc/ac-wrapper.sh /usr/bin/${x} || die
	done
}
