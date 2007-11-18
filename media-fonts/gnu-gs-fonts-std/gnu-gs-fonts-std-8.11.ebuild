# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-fonts/gnu-gs-fonts-std/gnu-gs-fonts-std-8.11.ebuild,v 1.10 2007/07/12 10:09:18 uberlord Exp $

EAPI="prefix"

MY_PN=ghostscript-fonts-std
MY_P=${MY_PN}-${PV}

DESCRIPTION="Ghostscript Standard Fonts"
HOMEPAGE="http://www.cups.org/"
SRC_URI="mirror://sourceforge/ghostscript/${MY_P}.tar.gz"

LICENSE="GPL-1"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=""

S=${WORKDIR}/fonts

src_install() {
	insinto /usr/share/fonts/default/ghostscript
	doins * || die
}
