# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/gzip/gzip-1.4.ebuild,v 1.11 2012/05/22 22:04:35 vapier Exp $

inherit eutils flag-o-matic prefix

DESCRIPTION="Standard GNU compressor"
HOMEPAGE="http://www.gnu.org/software/gzip/"
SRC_URI="mirror://gnu-alpha/gzip/${P}.tar.gz
	mirror://gnu/gzip/${P}.tar.gz
	mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls pic static"

RDEPEND=""
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	#epatch "${FILESDIR}"/${PN}-1.3.5-rsync.patch
	epatch "${FILESDIR}"/${PN}-1.3.8-install-symlinks.patch
	epatch "${FILESDIR}"/${P}-assembler.patch #309079
	epatch "${FILESDIR}"/${P}-no-gets.patch

	epatch "${FILESDIR}"/${P}-asmv.patch
	epatch "${FILESDIR}"/${PN}-1.3.12-prefix.patch
	eprefixify gzexe.in
}

src_compile() {
	use static && append-flags -static
	# avoid text relocation in gzip
	use pic && export DEFS="NO_ASM"
	econf || die
	emake || die
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc ChangeLog NEWS README THANKS TODO
	docinto txt
	dodoc algorithm.doc gzip.doc

	# keep most things in /usr, just the fun stuff in /
	dodir /bin
	mv "${ED}"/usr/bin/{gunzip,gzip,uncompress,zcat} "${ED}"/bin/ || die
	sed -e "s:${EPREFIX}/usr:${EPREFIX}:" -i "${ED}"/bin/gunzip || die
}
