# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/autoconf-wrapper/autoconf-wrapper-3.2-r2.ebuild,v 1.1 2006/06/27 00:51:05 vapier Exp $

EAPI="prefix"

DESCRIPTION="wrapper for autoconf to manage multiple autoconf versions"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-*"
IUSE=""

RDEPEND="~sys-devel/autoconf-2.60
	~sys-devel/autoconf-2.13"

S=${WORKDIR}

src_install() {
	exeinto /usr/lib/misc
	newexe "${FILESDIR}"/ac-wrapper-${PV}.sh ac-wrapper.sh || die
	dosed '/^binary_new=/s:2.59:2.60:' "${EPREFIX}"/usr/lib/misc/ac-wrapper.sh

	dodir /usr/bin
	local x=
	for x in auto{conf,header,m4te,reconf,scan,update} ifnames ; do
		dosym ../lib/misc/ac-wrapper.sh /usr/bin/${x} || die
	done
}
