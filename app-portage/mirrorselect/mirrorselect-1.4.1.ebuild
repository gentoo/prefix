# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/mirrorselect/mirrorselect-1.4.1.ebuild,v 1.1 2009/01/01 06:09:04 zmedico Exp $

EAPI="prefix"

inherit eutils prefix

DESCRIPTION="Tool to help select distfiles mirrors for Gentoo"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/${PF%.*}.tar.bz2 mirror://gentoo/$PF.patch.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

RDEPEND=">=dev-util/dialog-0.7
	net-analyzer/netselect"

S=$WORKDIR

src_unpack() {
	unpack $A
	epatch $PF.patch
	epatch "${FILESDIR}"/${PN}-1.4.1-prefix.patch
	eprefixify mirrorselect
}

src_install() {
	dosbin mirrorselect || die
}
