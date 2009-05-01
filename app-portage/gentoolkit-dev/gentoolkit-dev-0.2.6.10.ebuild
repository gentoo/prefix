# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/gentoolkit-dev/gentoolkit-dev-0.2.6.10.ebuild,v 1.1 2009/04/29 20:44:33 fuzzyray Exp $

inherit eutils

DESCRIPTION="Collection of developer scripts for Gentoo"
HOMEPAGE="http://www.gentoo.org/proj/en/portage/tools/index.xml"
SRC_URI="mirror://gentoo/${P}.tar.gz http://dev.gentoo.org/~fuzzyray/distfiles/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=">=sys-apps/portage-2.0.50
	>=dev-lang/python-2.0
	>=dev-util/dialog-0.7
	>=dev-lang/perl-5.6
	>=sys-apps/grep-2.4"
RDEPEND="$DEPEND"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-glep-53-keywords-sorting.patch
	sed -i -e "1s:^#!\( \|\):#!${EPREFIX}:" \
		src/*/{ebump,echangelog,ego,ekeyword,eviewcvs,gensync} || die "@!@#"
}

src_install() {
	make DESTDIR="${D}/${EPREFIX}" install-gentoolkit-dev || die
}

pkg_postinst() {
	ewarn "The gensync utility has been deprecated in favor of"
	ewarn "app-portage/layman. It is still available in"
	ewarn "${EROOT}usr/share/doc/${PF}/deprecated/ for use while"
	ewarn "you migrate to layman."
}
