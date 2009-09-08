# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/lout/lout-3.31.ebuild,v 1.4 2009/09/06 18:36:26 idl0r Exp $

inherit toolchain-funcs

IUSE="zlib doc"

DESCRIPTION="high-level language for document formatting"
HOMEPAGE="http://lout.sourceforge.net/"
SRC_URI="mirror://sourceforge/lout/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"

DEPEND="zlib? ( >=sys-libs/zlib-1.1.4 )"
RDEPEND="${DEPEND}"

src_compile() {
	local myconf
	use zlib && myconf="$myconf PDF_COMPRESSION=1 ZLIB=-lz"
	emake CC="$(tc-getCC)" BINDIR="${EPREFIX}"/usr/bin \
		LIBDIR="${EPREFIX}"/usr/share/lout \
		DOCDIR="${EPREFIX}"/usr/share/doc/${P} \
		MANDIR="${EPREFIX}"/usr/share/man/man1 \
		${myconf} lout prg2lout || die "emake prg2lout lout failed"
}

compile_doc() {
	#
	# SYNOPSIS:  compile_doc file times
	#

	einfo "${1}:"
	# yes, it *is* necessary to run this 6 times...
	for i in $(seq 1 $(expr $2 - 1)) ; do
		einfo " pass $i"
		lout all -o ${docdir}/$1 -e /dev/null
	done
	# in the last one, let errors be reported
	einfo " final pass"
	lout all -o ${docdir}/$1 || die "final pass failed"
}

src_install() {
	local bindir libdir docdir mandir
	bindir=${ED}/usr/bin
	libdir=${ED}/usr/share/lout
	docdir=${ED}/usr/share/doc/${P}
	mandir=${ED}/usr/share/man/man1
	export LOUTLIB=${libdir}
	export PATH="${bindir}:${PATH}"

	mkdir -p ${bindir} ${docdir} ${mandir}

	emake BINDIR=${bindir} \
		LIBDIR=${libdir} \
		DOCDIR=${docdir} \
		MANDIR=${mandir} \
		install installdoc installman || die "make install failed"

	lout -x -s "${ED}"/usr/share/lout/include/init || die "lout init failed"

	mv ${docdir}/README{,.docs}
	dodoc README READMEPDF blurb blurb.short whatsnew

	# stupid build system
	chmod 755 "${ED}"/usr/share/doc/${P}/doc/{design,expert,slides,user}

	if use doc ; then
		einfo "building postscript documentation (may take a while)"
		cd doc/user
		compile_doc user.ps 6
		cd ../design
		compile_doc design.ps 3
		cd ../expert
		compile_doc expert.ps 4
		cd ../slides
		compile_doc slides.ps 2
	fi
}
