# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/jpeg2ps/jpeg2ps-1.9-r1.ebuild,v 1.15 2008/01/26 10:37:58 grobian Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Converts JPEG images to Postscript using a wrapper"
HOMEPAGE="http://www.pdflib.com/download/free-software/jpeg2ps/"
SRC_URI="http://www.pdflib.com/products/more/jpeg2ps/${P}.tar.gz"

LICENSE="free-noncomm"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="sys-apps/sed"
RDEPEND=""

src_unpack() {
	unpack ${A}

	#bug 105561
	epatch "${FILESDIR}"/${P}-include.diff
}

src_compile() {
	pagesize=""
	if [ -h /etc/localtime ]; then
		local continent=$(readlink /etc/localtime | cut -d / -f 5)
		[ "${continent}" = "Europe" ] && pagesize="-DA4"
	fi
	emake CFLAGS="-c ${CFLAGS} ${pagesize}" || die "emake failed"
}

src_install() {
	# The Makefile is hard-coded to install to /usr/local/ so we
	# simply copy the files manually
	dobin jpeg2ps || die "dobin failed"
	doman jpeg2ps.1 || die "doman failed"
	dodoc jpeg2ps.txt || die "dodoc failed"
}

pkg_postinst() {
	elog
	if [ -z ${pagesize} ]; then
		elog "By default, this installation of jpeg2ps will generate"
		elog "letter size output.  You can force A4 output with"
		elog "    jpeg2ps -p a4 file.jpg > file.ps"
	else
		elog "By default, this installation of jpeg2ps will generate"
		elog "A4 size output.  You can force letter output with"
		elog "    jpeg2ps -p letter file.jpg > file.ps"
	fi
	elog
}
