# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/cpio/cpio-2.7-r2.ebuild,v 1.1 2007/04/18 19:40:39 vapier Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="A file archival tool which can also read and write tar files"
HOMEPAGE="http://www.gnu.org/software/cpio/cpio.html"
SRC_URI="mirror://gnu/cpio/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-aix ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE="nls"

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-2.7-link-terminate.patch #153782
	epatch "${FILESDIR}"/${PN}-2.7-copypass.patch #174921
}

src_compile() {
	econf \
		$(use_enable nls) \
		$(with_bindir) \
		--with-rmt=${EPREFIX}/usr/sbin/rmt \
		|| die
	emake || die
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc ChangeLog NEWS README
	rm -f "${ED}"/usr/share/man/man1/mt.1
	rmdir "${ED}"/usr/libexec || die
}
