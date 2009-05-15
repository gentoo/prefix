# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/gentoolkit-dev/gentoolkit-dev-0.2.6.11-r2.ebuild,v 1.1 2009/05/12 18:57:11 idl0r Exp $

EAPI="2"

inherit eutils

DESCRIPTION="Collection of developer scripts for Gentoo"
HOMEPAGE="http://www.gentoo.org/proj/en/portage/tools/index.xml"
SRC_URI="mirror://gentoo/${P}.tar.gz http://dev.gentoo.org/~fuzzyray/distfiles/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="sys-apps/portage
	dev-lang/perl"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}/echangelog.patch"

	sed -i -e "1s:^#!\( \|\):#!${EPREFIX}:" \
		src/*/{ebump,echangelog,ego,ekeyword,eviewcvs} || die "@!@#"
}

src_install() {
	make DESTDIR="${D}/${EPREFIX}" install-gentoolkit-dev || die
}
