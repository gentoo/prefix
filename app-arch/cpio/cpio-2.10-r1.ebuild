# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/cpio/cpio-2.10-r1.ebuild,v 1.3 2010/03/12 18:55:08 ranger Exp $

EAPI=2

inherit eutils flag-o-matic

DESCRIPTION="A file archival tool which can also read and write tar files"
HOMEPAGE="http://www.gnu.org/software/cpio/cpio.html"
SRC_URI="mirror://gnu/cpio/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls"

src_prepare() {
	# Per here: http://lists.gnu.org/archive/html/bug-cpio/2009-10/msg00000.html
	# fixes hardlink creation from XFS
	epatch "${FILESDIR}"/cpio-2.9-64-bit-wide-inode-fixup.patch

	epatch "${FILESDIR}"/${P}-irix.patch
}

src_configure() {
	# GNU is not Linux :(
	[[ ${CHOST} == *-solaris* ]] && append-libs nsl # gethostbyname
	econf \
		$(use_enable nls) \
		--bindir="${EPREFIX}"/bin \
		--with-rmt="${EPREFIX}"/usr/sbin/rmt \
		|| die
}

src_compile() {
	emake || die
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc ChangeLog NEWS README
	rm -f "${ED}"/usr/share/man/man1/mt.1
	rmdir "${ED}"/usr/libexec || die
}
