# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/gzip/gzip-1.3.12.ebuild,v 1.12 2007/07/20 16:34:15 uberlord Exp $

EAPI="prefix"

inherit eutils flag-o-matic

DESCRIPTION="Standard GNU compressor"
HOMEPAGE="http://www.gnu.org/software/gzip/"
SRC_URI="ftp://alpha.gnu.org/gnu/gzip/${P}.tar.gz
	mirror://gnu/gzip/${P}.tar.gz
	mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls static pic"

RDEPEND=""
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"
PROVIDE="virtual/gzip"

src_unpack() {
	unpack ${A}
	cd "${S}"
	#epatch "${FILESDIR}"/${PN}-1.3.5-rsync.patch
	epatch "${FILESDIR}"/gnulib-futimens-rename.patch
	epatch "${FILESDIR}"/${PN}-1.3.8-install-symlinks.patch
	sed -i 's:\<futimens\>:gl_futimens:' gzip.c

	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify \
		g{unzip,zexe}.in \
		z{cat,cmp,diff,egrep,fgrep,force,grep,less,more,new}.in
}

src_compile() {
	use static && append-flags -static
	# avoid text relocation in gzip
	use pic && export DEFS="NO_ASM"
	# darwin and asm is still a no-no
	[[ ${CHOST} == *-darwin* ]] && export DEFS="NO_ASM"
	econf $(use_enable nls) || die
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
}
