# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/autoconf-wrapper/autoconf-wrapper-3.2.ebuild,v 1.12 2006/11/03 18:39:27 grobian Exp $

EAPI="prefix"

DESCRIPTION="wrapper for autoconf to manage multiple autoconf versions"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""

RDEPEND=">=sys-devel/autoconf-2.59-r6
	~sys-devel/autoconf-2.13"

S=${WORKDIR}

src_install() {
	exeinto /usr/lib/misc
	newexe ${FILESDIR}/ac-wrapper-${PV}.sh ac-wrapper.sh || die

	dodir /usr/bin
	local x=
	for x in auto{conf,header,m4te,reconf,scan,update} ifnames ; do
		dosym ../lib/misc/ac-wrapper.sh /usr/bin/${x} || die
	done
}
