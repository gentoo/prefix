# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-fs/curlftpfs/curlftpfs-0.9.2-r1.ebuild,v 1.1 2009/12/10 22:07:32 fauli Exp $


EAPI=2

inherit eutils autotools

DESCRIPTION="File system for accessing ftp hosts based on FUSE"
HOMEPAGE="http://curlftpfs.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""
RESTRICT="test" # bug 258460

DEPEND=">=net-misc/curl-7.17.0
	>=sys-fs/fuse-2.2
	>=dev-libs/glib-2.0"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${P}-64bit_filesize.patch
	epatch ${FILESDIR}/${PN}-0.9.2-darwin.patch
	eautoreconf
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc README
}
