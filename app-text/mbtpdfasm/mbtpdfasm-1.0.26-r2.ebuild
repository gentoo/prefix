# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/mbtpdfasm/mbtpdfasm-1.0.26-r2.ebuild,v 1.1 2006/07/26 16:38:37 sbriesen Exp $

inherit eutils toolchain-funcs

MY_P="mbtPdfAsm-${PV}"

DESCRIPTION="mbtPdfAsm can assemble/merge PDF files, extract information from PDF files, and update the metadata in PDF files."
HOMEPAGE="http://thierry.schmit.free.fr/dev/mbtPdfAsm/enMbtPdfAsm2.html"
SRC_URI="http://thierry.schmit.free.fr/dev/mbtPdfAsm/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris"
IUSE="unicode"

DEPEND=""

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	edos2unix *.txt
	epatch "${FILESDIR}/${P}-gcc4.patch"
	epatch "${FILESDIR}/${P}-64bit.patch"

	# patch location of help files
	sed -i -e "s:\(aide.txt\):${EPREFIX}/usr/share/doc/${PF}/\1:g" \
		 -e "s:\(help.txt\):${EPREFIX}/usr/share/doc/${PF}/\1:g" string.cpp

	# convert to UTF-8
	if use unicode; then
		for i in aide.txt; do
			einfo "Converting ${i} to UTF-8"
			iconv -f latin1 -t UTF-8 "${i}" > "${i}~" && mv -f "${i}~" "${i}" || rm -f "${i}~"
		done
	fi
}

src_compile() {
	# FIXME: ugly, but this way we don't need to patch anything
	emake CC="$(tc-getCXX) ${CXXFLAGS}" || die "emake failed"
}

src_install() {
	dobin mbtPdfAsm || die "install failed"
	insinto /usr/share/doc/${PF}
	doins *.txt  # do not gzip!
}
