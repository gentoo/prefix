# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/autoconf-archive/autoconf-archive-2008.11.07.ebuild,v 1.1 2009/01/29 16:11:24 vapier Exp $

inherit eutils

MY_PV=${PV//./-}
DESCRIPTION="GNU Autoconf Macro Archive"
HOMEPAGE="http://autoconf-archive.cryp.to/"
SRC_URI="http://autoconf-archive.cryp.to/${PN}-${MY_PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

S=${WORKDIR}/${PN}-${MY_PV}

src_install() {
	emake install DESTDIR="${D}" || die
	dodir /usr/share/doc
	mv "${ED}"/usr/share/{${PN},doc/${PF}} || die
}
