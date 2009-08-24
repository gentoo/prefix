# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/jpeg/jpeg-7.ebuild,v 1.7 2009/08/23 14:33:07 ssuominen Exp $

EAPI="2"

DEB_PV="7-1"
DEB_PN="libjpeg${PV}"
DEB="${DEB_PN}_${DEB_PV}"

inherit eutils libtool

DESCRIPTION="Library to load, handle and manipulate images in the JPEG format"
HOMEPAGE="http://jpegclub.org/ http://www.ijg.org/"
SRC_URI="http://www.ijg.org/files/${PN}src.v${PV}.tar.gz
	mirror://debian/pool/main/libj/${DEB_PN}/${DEB}.diff.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${WORKDIR}"/${DEB}.diff
	cp "${FILESDIR}"/Makefile.extra debian/extra/Makefile
	cp "${FILESDIR}"/Makefile.in.extra debian/extra/Makefile.in
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-maxmem_sysconf.patch
	elibtoolize
	# hook the Debian extra dir into the normal jpeg build env
	sed -i '/all:/s:$:\n\t$(MAKE) -C debian/extra $@:' Makefile.in
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		--enable-shared \
		--enable-static \
		--enable-maxmem=64
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc change.log example.c README *.txt
}
