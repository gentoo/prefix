# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/xv/xv-3.10a-r14.ebuild,v 1.7 2007/11/09 22:32:58 grobian Exp $

EAPI="prefix"

inherit flag-o-matic eutils toolchain-funcs

JUMBOV=20070520
DESCRIPTION="An interactive image manipulation program for X, supporting a wide variety of image formats"
HOMEPAGE="http://www.trilon.com/xv/index.html http://www.sonic.net/~roelofs/greg_xv.html"
SRC_URI="mirror://sourceforge/png-mng/${P}-jumbo-patches-${JUMBOV}.tar.gz ftp://ftp.cis.upenn.edu/pub/xv/${P}.tar.gz"

LICENSE="xv"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="jpeg tiff png"

DEPEND="x11-libs/libXt
	jpeg? ( >=media-libs/jpeg-6b )
	tiff? ( >=media-libs/tiff-3.6.1-r2 )
	png? ( >=media-libs/libpng-1.2 >=sys-libs/zlib-1.1.4 )"
RDEPEND=${DEPEND}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Apply the jumbo patch
	epatch "${WORKDIR}/${P}"-jumbo-fix-enh-patch-${JUMBOV}.txt

	# OSX and BSD xv.h define patches
	epatch "${FILESDIR}/${P}"-osx-bsd-${JUMBOV}.patch

	# OSX malloc patch
	epatch "${FILESDIR}/${P}"-vdcomp-osx-${JUMBOV}.patch

	# Disable JP2K (i.e. use system JPEG libs)
	epatch "${FILESDIR}/${P}"-disable-jp2k-${JUMBOV}.patch

	sed -i	-e 's/\(^JPEG.*\)/#\1/g' \
			-e 's/\(^PNG.*\)/#\1/g' \
			-e 's/\(^TIFF.*\)/#\1/g' \
			-e 's/\(^LIBS = .*\)/\1 $(LDFLAGS) /g' Makefile

	# /usr/bin/gzip => /bin/gzip
	sed -i	-e 's#/usr\(/bin/gzip\)#'"${EPREFIX}"'\1#g' config.h

	# fix installation of ps docs.
	sed -i -e 's#$(DESTDIR)$(LIBDIR)#$(LIBDIR)#g' Makefile
}

src_compile() {
	append-flags -DUSE_GETCWD -DLINUX -DUSLEEP

	einfo "Enabling Optional Features..."
	if use jpeg; then
		ebegin "	jpeg"
			append-flags -DDOJPEG
			append-ldflags -ljpeg
		eend
	fi
	if use png; then
		ebegin "	png"
			append-flags -DDOPNG
			append-ldflags -lz -lpng
		eend
	fi
	if use tiff; then
		ebegin "	tiff"
			append-flags -DDOTIFF -DUSE_TILED_TIFF_BOTLEFT_FIX
			append-ldflags -ltiff
		eend
	fi
	einfo "done."

	emake	CC="$(tc-getCC)" CCOPTS="${CFLAGS}" LDFLAGS="${LDFLAGS}" \
			PREFIX="${EPREFIX}"/usr \
			DOCDIR="${EPREFIX}"/usr/share/doc/${P} \
			LIBDIR=${T} || die
}

src_install() {
	dodir /usr/bin
	dodir /usr/share/man/man1

	emake	DESTDIR=${D} \
			PREFIX="${EPREFIX}"/usr \
			DOCDIR="${EPREFIX}"/usr/share/doc/${PF} \
			LIBDIR=${T} install || die

	dodoc CHANGELOG BUGS IDEAS
}
