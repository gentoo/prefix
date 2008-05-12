# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-ftp/ncftp/ncftp-3.2.1.ebuild,v 1.9 2008/05/11 08:35:57 solar Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

IPV6_P="ncftp-321-v6-20070822"
DESCRIPTION="An extremely configurable ftp client"
HOMEPAGE="http://www.ncftp.com/"
SRC_URI="ftp://ftp.ncftp.com/ncftp/${P}-src.tar.bz2
	ipv6? ( ftp://ftp.kame.net/pub/kame/misc/${IPV6_P}.diff.gz )"

LICENSE="Clarified-Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE="ipv6"

DEPEND=">=sys-libs/ncurses-5.2"

src_unpack() {
	unpack ${A}
	cd "${S}"
	use ipv6 && epatch "${DISTDIR}"/${IPV6_P}.diff.gz
	epatch "${FILESDIR}"/${P}-build.patch #147371
	tc-export CC
	sed -i \
		-e s/CC=gcc/"CC ?= ${CC}"/ \
		-e 's:@SFLAG@::' \
		-e 's:@STRIP@:true:' \
		Makefile.in */Makefile.in || die
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc README.txt doc/*.txt
	dohtml doc/html/*.html
}
