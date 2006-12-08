# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/gzip/gzip-1.3.7.ebuild,v 1.1 2006/12/07 13:56:37 vapier Exp $

EAPI="prefix"

inherit eutils flag-o-matic

DESCRIPTION="Standard GNU compressor"
HOMEPAGE="http://www.gnu.org/software/gzip/gzip.html"
SRC_URI="ftp://alpha.gnu.org/gnu/gzip/${P}.tar.gz
	mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="nls static pic"

RDEPEND=""
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"
PROVIDE="virtual/gzip"

src_unpack() {
	unpack ${A}
	cd "${S}"
	#epatch "${FILESDIR}"/${PN}-1.3.7-CVE-2006-4334-8.2.patch
	epatch "${FILESDIR}"/${PN}-1.3.5-znew-tempfile-2.patch
	epatch "${FILESDIR}"/${PN}-1.3.7-asm-execstack.patch
	#epatch "${FILESDIR}"/${PN}-1.3.5-rsync.patch
	epatch "${FILESDIR}"/${PN}-1.3.5-alpha.patch
	epatch "${FILESDIR}"/${PN}-1.3.7-install-symlinks.patch
}

src_compile() {
	use static && append-flags -static
	# avoid text relocation in gzip
	use pic || [[ $USERLAND == "Darwin" ]] && export DEFS="NO_ASM"
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
	mv "${ED}"/usr/bin/{gunzip,gzip,zcat} "${ED}"/bin/ || die
	dosym /bin/gunzip /usr/bin/gunzip || die
}
