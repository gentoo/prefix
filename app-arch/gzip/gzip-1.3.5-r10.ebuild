# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/gzip/gzip-1.3.5-r10.ebuild,v 1.2 2006/10/17 12:52:28 uberlord Exp $

EAPI="prefix"

inherit eutils flag-o-matic

DESCRIPTION="Standard GNU compressor"
HOMEPAGE="http://www.gnu.org/software/gzip/gzip.html"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="nls build static pic"

RDEPEND=""
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"
PROVIDE="virtual/gzip"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-CVE-2006-4334-8.2.patch
	epatch "${FILESDIR}"/${P}-debian.patch
	epatch "${FILESDIR}"/${P}-znew-tempfile-2.patch
	epatch "${FILESDIR}"/${P}-gunzip-dir.patch
	epatch "${FILESDIR}"/${P}-asm-execstack.patch
	epatch "${FILESDIR}"/${P}-gzip-perm.patch
	epatch "${FILESDIR}"/${P}-infodir.patch
	epatch "${FILESDIR}"/${P}-rsync.patch
	epatch "${FILESDIR}"/${P}-zgrep-sed.patch
	epatch "${FILESDIR}"/${P}-alpha.patch
	epatch "${FILESDIR}"/${P}-zgreppipe.patch
}

src_compile() {
	use static && append-flags -static
	# avoid text relocation in gzip
	use pic || [[ $USERLAND == "Darwin" ]] && export DEFS="NO_ASM"
	append-ldflags -L${EPREFIX}/lib -lz
	econf --exec-prefix=${EPREFIX}/ $(use_enable nls) || die
	emake || die
}

src_install() {
	dodir /usr/bin /usr/share/man/man1
	make prefix=${ED}/usr \
		exec_prefix=${ED}/ \
		mandir=${ED}/usr/share/man \
		infodir=${ED}/usr/share/info \
		install || die

	cd ${ED}/bin

	for i in gzexe zforce zgrep zmore znew zcmp
	do
		sed -i -e "s:${ED}::" ${i} || die
		chmod 755 ${i}
	done

	# No need to waste space -- these guys should be links
	# gzcat is equivilant to zcat, but historically zcat
	# was a link to compress.
	rm -f gunzip zcat zcmp zegrep zfgrep
	dosym gzip /bin/gunzip
	dosym gzip /bin/gzcat
	dosym gzip /bin/zcat
	dosym zdiff /bin/zcmp
	dosym zgrep /bin/zegrep
	dosym zgrep /bin/zfgrep

	if ! use build
	then
		cd ${ED}/usr/share/man/man1
		rm -f gunzip.* zcmp.* zcat.*
		ln -s gzip.1.gz gunzip.1.gz
		ln -s zdiff.1.gz zcmp.1.gz
		ln -s gzip.1.gz zcat.1.gz
		ln -s gzip.1.gz gzcat.1.gz
		cd ${S}
		rm -rf ${ED}/usr/man ${ED}/usr/lib
		dodoc ChangeLog NEWS README THANKS TODO
		docinto txt
		dodoc algorithm.doc gzip.doc
	else
		rm -rf ${ED}/usr
	fi
}
