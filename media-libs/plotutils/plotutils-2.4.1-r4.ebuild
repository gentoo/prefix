# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/plotutils/plotutils-2.4.1-r4.ebuild,v 1.11 2007/04/30 23:33:16 genone Exp $

EAPI="prefix"

inherit libtool eutils flag-o-matic

#The plotutils package contains extra X fonts.	These fonts are not installed
#in the current ebuild.	 The commented out ebuild lines below are for future
#reference when this ebuild may be updated to install the fonts.
#NOTE: The current method does not play nice with X and sandbox.  Most of the
#font installation procedures should probably be moved to pkg_postinst.
#See Bug# 30 at http://bugs.gentoo.org/show_bug.cgi?id=30

DESCRIPTION="a powerful C/C++ function library for exporting 2-D vector graphics"
HOMEPAGE="http://www.gnu.org/software/plotutils/"
SRC_URI="mirror://gnu/plotutils/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE="X"

DEPEND="media-libs/libpng
	X? ( || ( ( x11-libs/libXaw
				x11-proto/xextproto
			)
			virtual/x11
		)
	)"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/plotutils-2.4.1-gentoo.patch"
	epatch "${FILESDIR}/plotutils-2.4.1-rangecheck.patch"
	epatch "${FILESDIR}/plotutils-2.4.1-correct_test.patch"

}

src_compile() {
	replace-cpu-flags k6 k6-2 k6-3 i586
	elibtoolize

	#enable build of C++ version
	local myconf="--enable-libplotter"

	#The following two additional configure options may be of interest
	#to users with specific printers, i.e. HP LaserJets with PCL 5 or HP-GL/2.
	#Not sure if enabling screws the pooch for those without these printers.
	#--enable-ps-fonts-in-pcl --enable-lj-fonts-in-ps

	use X \
		&& myconf="${myconf} --with-x --enable-libxmi" \
		|| myconf="${myconf} --without-x"

	econf ${myconf} || die "./configure failed"
	emake || die "Parallel Make Failed"
}

src_install() {
	einstall datadir="${ED}/usr/share" || die "Installation Failed"

	dodoc AUTHORS COMPAT ChangeLog INSTALL* \
		KNOWN_BUGS NEWS ONEWS PROBLEMS README THANKS TODO
}

pkg_postinst() {
	if use X; then
		elog "There are extra fonts available in plotutils package."
		elog "The current ebuild does not install them for you."
		elog "You may want to do so, but you will have to do it"
		elog "manually. You are on your own for now."
		elog "See /usr/share/doc/${P}/INSTALL.fonts"
		elog ""
		elog "If you manually install the extra fonts and use the"
		elog "program xfig, you might want to recompile to take"
		elog "advantage of the additional ps fonts."
		elog "Also, it is possible to enable ghostscript and possibly"
		elog "your printer to use the HP fonts."
	fi
}
