# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/xloadimage/xloadimage-4.1-r5.ebuild,v 1.2 2008/01/15 18:37:57 grobian Exp $

inherit alternatives eutils toolchain-funcs

MY_P="${P/-/.}"
S=${WORKDIR}/${MY_P}
DESCRIPTION="utility to view many different types of images under X11"
HOMEPAGE="http://world.std.com/~jimf/xloadimage.html"
SRC_URI="ftp://ftp.x.org/R5contrib/${MY_P}.tar.gz
	mirror://gentoo/${P}-gentoo.diff.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="tiff jpeg png"

RDEPEND="x11-libs/libX11
	tiff? ( media-libs/tiff )
	png? ( media-libs/libpng )
	jpeg? ( media-libs/jpeg )"
DEPEND="${RDEPEND}
	>=sys-apps/sed-4.0.5"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${WORKDIR}"/${P}-gentoo.diff
	epatch "${FILESDIR}"/${P}-zio-shell-meta-char.diff
	epatch "${FILESDIR}"/${P}-endif.patch

	# Do not define errno extern, but rather include errno.h
	# <azarah@gentoo.org> (1 Jan 2003)
	epatch "${FILESDIR}"/${P}-include-errno_h.patch

	epatch "${FILESDIR}"/xloadimage-gentoo.patch

	sed -i "s:OPT_FLAGS=:OPT_FLAGS=$CFLAGS:" Make.conf
	sed -i "s:^#include <varargs.h>:#include <stdarg.h>:" "${S}"/rlelib.c

	# On FreeBSD systems malloc.h is a false header asking for fixes.
	# On MacOSX it would require malloc/malloc.h
	# On other systems it's simply unneeded
	sed -i -e 's,<malloc.h>,<stdlib.h>,' vicar.c

	for f in $(grep zopen * | cut -d':' -f1 | uniq);do
		sed -i "s:zopen:zloadimage_zopen:g" $f
	done

	epatch "${FILESDIR}"/${P}-unaligned-access.patch

	sed -i -e "/^DEFS = /s:/etc:${EPREFIX}/etc:" Makefile.in
	chmod +x "${S}"/configure
}

src_compile() {
	tc-export CC
	econf || die "econf failed."
	emake SYSPATHFILE="${EPREFIX}"/etc/X11/Xloadimage || die "emake failed."
}

src_install() {
	dobin xloadimage uufilter

	insinto /etc/X11
	doins xloadimagerc

	newman xloadimage.man xloadimage.1
	newman uufilter.man uufilter.1

	dodoc README
}

update_alternatives() {
	local mansuffix=$(ecompress --suffix)

	alternatives_makesym /usr/bin/xview \
		/usr/bin/{xloadimage,xli}
	alternatives_makesym /usr/bin/xsetbg \
		/usr/bin/{xloadimage,xli}
	alternatives_makesym /usr/share/man/man1/xview.1${mansuffix} \
		/usr/share/man/man1/{xloadimage,xli}.1${mansuffix}
	alternatives_makesym /usr/share/man/man1/xsetbg.1${mansuffix} \
		/usr/share/man/man1/{xloadimage,xli}.1${mansuffix}
}

pkg_postinst() {
	update_alternatives
}

pkg_postrm() {
	update_alternatives
}
