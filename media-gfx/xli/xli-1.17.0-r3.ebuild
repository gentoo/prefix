# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/xli/xli-1.17.0-r3.ebuild,v 1.3 2008/01/15 18:33:24 grobian Exp $

EAPI="prefix"

inherit alternatives eutils

SNAPSHOT="2005-02-27"
DESCRIPTION="X Load Image: view images or load them to root window"
HOMEPAGE="http://pantransit.reptiles.org/prog/"
SRC_URI="http://pantransit.reptiles.org/prog/xli/xli-${SNAPSHOT}.tar.gz"

LICENSE="X11"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

RDEPEND="x11-libs/libXext
	>=sys-libs/zlib-1.1.4
	>=media-libs/libpng-1.0.5
	>=media-libs/jpeg-6b-r2
	app-arch/bzip2"
DEPEND="${RDEPEND}
	x11-proto/xextproto
	x11-misc/imake
	app-text/rman"

S="${WORKDIR}"/${PN}-${SNAPSHOT}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# avoid conflicts on systems that have zopen in system headers
	for f in $(grep zopen * | cut -d':' -f1 | uniq); do
		sed -i -e "s:zopen:xli_zopen:g" $f
	done

	sed -i Imakefile \
		-e "/^DEFINES =/s/$/ -DHAVE_GUNZIP -DHAVE_BUNZIP2 /" \
		-e "/CCOPTIONS =/s/=.*/=/"

	# This is a hack to avoid a parse error on /usr/include/string.h
	# when _BSD_SOURCE is defined. This may be a bug in that header.
	sed	-i png.c \
		-e "/^#include \"xli.h\"/i#undef _BSD_SOURCE"

	# This hack will allow xli to compile using gcc-3.3
	sed -i rlelib.c \
		-e "s/#include <varargs.h>//"

	# fix potential security issues.
	EPATCH_OPTS="-F3 -l" epatch ${FILESDIR}/xli-security-gentoo.diff
}

src_compile() {
	xmkmf || die "xmkmf failed."

	emake CDEBUGFLAGS="${CFLAGS}" || die "emake failed."
}

src_install() {
	dobin xli xlito
	dodoc README README.xloadimage ABOUTGAMMA TODO chkgamma.jpg
	newman xli.man xli.1
	newman xliguide.man xliguide.1
	newman xlito.man xlito.1

	insinto /etc/X11/app-defaults
	newins ${FILESDIR}/Xli.ad Xli
	fperms a+r /etc/X11/app-defaults/Xli
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
