# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/java-config-wrapper/java-config-wrapper-0.14.ebuild,v 1.7 2008/01/10 09:59:04 vapier Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Wrapper for java-config"
HOMEPAGE="http://www.gentoo.org/proj/en/java"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND="!<dev-java/java-config-1.3"
RDEPEND="app-portage/portage-utils"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify src/shell/java-{1.5-fixer,check-environment,config}
}

src_install() {
	dobin src/shell/* || die
	dodoc ChangeLog AUTHORS || die
}
