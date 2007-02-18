# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/Xaw3d/Xaw3d-1.5-r1.ebuild,v 1.35 2007/02/10 14:57:09 grobian Exp $

EAPI="prefix"

# Ok, hopefully this will resolv the problem with the version of libXaw3d that
# gets created.
#
# The problem its seems, is that when X gets compiled, it determines (with the
# help of some very dark magic) what version libXaw.so it it should build (6.1 or
# 7.0).  Now, when compiling Xaw3d, it checks which version of Xaw was built, and
# then builds the same version of Xaw3d.
#
# Since this ebuild use the Makefile's "install" function, it "should" not be a
# problem anymore.
#
# Azarah.

inherit eutils toolchain-funcs

S=${WORKDIR}/xc/lib/Xaw3d
DESCRIPTION="drop-in 3D replacement of the Xaw widget set which comes with X"
HOMEPAGE="http://freshmeat.net/projects/xaw3d/"
# All full ftp.x.org mirrors can be added here.
SRC_URI="ftp://ftp.x.org/contrib/widgets/Xaw3d/R6.3/${P}.tar.gz
	http://ibiblio.org/pub/X11/contrib/widgets/Xaw3d/R6.3/${P}.tar.gz"

LICENSE="X11"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

# There _might_ be something else, but I doubt it.
RDEPEND="x11-libs/libXt
		x11-libs/libX11
		x11-libs/libXmu
		x11-libs/libXpm
		x11-libs/libXp"

DEPEND="${RDEPEND}
	>=sys-apps/sed-4
	x11-misc/imake
	x11-misc/gccmakedep"

src_unpack() {
	unpack ${P}.tar.gz
	cd ${S}

	# For some reason it isn't automatically patched.
	# That's why I manually override the source_unpack function.
	epatch ${FILESDIR}/Xaw3d-xfree86.diff
	epatch ${FILESDIR}/Xaw3d-out-of-tree.diff

	# This adds more familiar scroll-bar look and feel for Emacs and
	# others <mkennedy@gentoo.org>
	sed -i -e 's,#.*EXTRA_DEFINES,EXTRA_DEFINES,g' Imakefile || die
}

src_compile() {
	# convoluted process for out-of-tree building
	mkdir ./X11
	cd ./X11 ; ln -sf ../../Xaw3d . ; cd ..

	xmkmf || die
	make includes || die
	make depend || die
	emake CDEBUGFLAGS="${CFLAGS}" CC="$(tc-getCC)" || die
}

src_install() {
	make INSTALLFLAGS="-c" DESTDIR="${D}" install || die

	dodoc README.XAW3D
}
