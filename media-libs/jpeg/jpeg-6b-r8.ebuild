# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/jpeg/jpeg-6b-r8.ebuild,v 1.14 2008/08/16 14:46:39 vapier Exp $

inherit libtool eutils toolchain-funcs

PATCH_VER="1.6"
DESCRIPTION="Library to load, handle and manipulate images in the JPEG format"
HOMEPAGE="http://www.ijg.org/"
SRC_URI="ftp://ftp.uu.net/graphics/jpeg/${PN}src.v${PV}.tar.gz
	mirror://gentoo/${P}-patches-${PATCH_VER}.tar.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	>=sys-devel/libtool-1.5.10-r4"

src_unpack() {
	unpack ${A}
	cd "${S}"
	EPATCH_SUFFIX="patch" epatch "${WORKDIR}"/patch
	epatch "${FILESDIR}"/${P}-freebsd.patch

	# hrmm. this is supposed to update it.
	# true, the bug is here:
	rm libtool-wrap
	ln -s libtool libtool-wrap
	elibtoolize
}

src_compile() {
	tc-export CC RANLIB AR
	econf \
		--enable-shared \
		--enable-static \
		--enable-maxmem=64 \
		|| die "econf failed"
	emake || die "make failed"
	emake -C "${WORKDIR}"/extra || die "make extra failed"
}

src_install() {
	emake install DESTDIR="${D}" || die "install"
	emake -C "${WORKDIR}"/extra install DESTDIR="${D}${EPREFIX}" || die "install extra"

	dodoc README install.doc usage.doc wizard.doc change.log \
		libjpeg.doc example.c structure.doc filelist.doc \
		coderules.doc
}
