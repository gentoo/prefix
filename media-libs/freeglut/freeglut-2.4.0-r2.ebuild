# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/freeglut/freeglut-2.4.0-r2.ebuild,v 1.1 2009/08/21 08:23:13 scarabeus Exp $

inherit eutils flag-o-matic libtool autotools

DESCRIPTION="A completely OpenSourced alternative to the OpenGL Utility Toolkit (GLUT) library"
HOMEPAGE="http://freeglut.sourceforge.net/"
SRC_URI="mirror://sourceforge/freeglut/${P}.tar.gz"

LICENSE="X11"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

RDEPEND="virtual/opengl
	virtual/glu
	!media-libs/glut"
DEPEND="${RDEPEND}"

pkg_setup() {
	# bug #134586
	if [[ ${CFLAGS/march/} = ${CFLAGS} ]]; then
		ewarn "You do not have 'march' set in your CFLAGS."
		ewarn "This is known to cause compilation problems"
		ewarn "in ${P}.  If the compile fails, please set"
		ewarn "'march' to the appropriate architecture."
		epause 5
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# fixes bug #97390
	epatch "${FILESDIR}"/${P}-macos.patch

	# #131856
	epatch "${FILESDIR}"/${PN}-gcc42.patch

	# (#140542) fix cursor handling so flightgear works
	epatch "${FILESDIR}"/${PV}-cursor.patch

	# Disable BSD's usb joystick support, see reasons in the patch
	epatch "${FILESDIR}"/${P}-bsd-usb-joystick.patch

	# bug #134586
	replace-flags -O3 -O2

	# Needed for sane .so versionning on bsd, please don't drop
	elibtoolize
	eautoreconf
}

src_compile() {
	# (#191589) Don't let -Werror get tagged on
	econf --disable-warnings || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README TODO || die "dodoc failed"
	dohtml -r doc/*.html doc/*.png || die "dohtml failed"
}
