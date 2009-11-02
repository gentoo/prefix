# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/gzip/gzip-1.3.13.ebuild,v 1.1 2009/10/06 21:20:14 vapier Exp $

inherit eutils flag-o-matic prefix

DESCRIPTION="Standard GNU compressor"
HOMEPAGE="http://www.gnu.org/software/gzip/"
SRC_URI="ftp://alpha.gnu.org/gnu/gzip/${P}.tar.gz
	mirror://gnu/gzip/${P}.tar.gz
	mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls static pic"

RDEPEND=""
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"
PROVIDE="virtual/gzip"

src_unpack() {
	unpack ${A}
	cd "${S}"
	#epatch "${FILESDIR}"/${PN}-1.3.5-rsync.patch
	epatch "${FILESDIR}"/${PN}-1.3.8-install-symlinks.patch

	epatch "${FILESDIR}"/${PN}-1.3.12-mint.patch
	epatch "${FILESDIR}"/${PN}-1.3.13-darwin.patch
	epatch "${FILESDIR}"/${PN}-1.3.12-prefix.patch
	epatch "${FILESDIR}"/${PN}-1.3.13-gl-stat-aix-largefiles.patch
	eprefixify \
		g{unzip,zexe}.in \
		z{cat,cmp,diff,egrep,fgrep,force,grep,less,more,new}.in
}

src_compile() {
	use static && append-flags -static
	# avoid text relocation in gzip
	use pic && export DEFS="NO_ASM"
#	# darwin and asm is still a no-no
#	[[ ${CHOST} == *-darwin* ]] && export DEFS="NO_ASM"
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
	sed -e 's:/usr::' -i "${ED}"/bin/gunzip || die
}
