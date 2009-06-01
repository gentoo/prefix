# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/cpio/cpio-2.9-r3.ebuild,v 1.1 2009/01/17 17:57:05 vapier Exp $

inherit eutils flag-o-matic

DESCRIPTION="A file archival tool which can also read and write tar files"
HOMEPAGE="http://www.gnu.org/software/cpio/cpio.html"
SRC_URI="mirror://gnu/cpio/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls"

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-CVE-2007-4476.patch #196978
	epatch "${FILESDIR}"/${P}-gnu-inline.patch #198817
	epatch "${FILESDIR}"/${P}-restore-perms-owners.patch #218040
	epatch "${FILESDIR}"/${P}-packed.patch #255096
}

src_compile() {
	# hack around ld: duplicate symbol _argp_fmtstream_putc problem
	[[ ${CHOST} == *-darwin* ]] && append-flags -U__OPTIMIZE__
	econf \
		$(use_enable nls) \
		--bindir="${EPREFIX}"/bin \
		--with-rmt="${EPREFIX}"/usr/sbin/rmt \
		|| die
	emake || die
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc ChangeLog NEWS README
	rm -f "${ED}"/usr/share/man/man1/mt.1
	rmdir "${ED}"/usr/libexec || die
}
