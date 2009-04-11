# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libafterimage/libafterimage-1.15.ebuild,v 1.13 2008/04/08 09:20:34 armin76 Exp $

inherit eutils

MY_PN="libAfterImage"

DESCRIPTION="Afterstep's standalone generic image manipulation library"
HOMEPAGE="http://www.afterstep.org/afterimage/index.php"
SRC_URI="ftp://ftp.afterstep.org/stable/${MY_PN}/${MY_PN}-${PV}.tar.bz2"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="gif jpeg mmx nls png tiff examples"

RDEPEND="media-libs/freetype
	x11-libs/libSM
	x11-libs/libXext
	x11-libs/libXrender
	png?  ( >=media-libs/libpng-1.2.5 )
	jpeg? ( >=media-libs/jpeg-6b )
	gif?  ( >=media-libs/giflib-4.1 )
	tiff? ( >=media-libs/tiff-3.5.7 )"

DEPEND="${RDEPEND}
	!x11-wm/afterstep"

S="${WORKDIR}/${MY_PN}-${PV}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# fix apps makefile
	epatch "${FILESDIR}"/${P}-examples.patch
	# fix some ldconfig problem in makefile.in
	epatch "${FILESDIR}"/${PN}-makefile.in.patch
	# fix lib paths in afterimage-config
	epatch "${FILESDIR}"/${PN}-config.patch
	# remove forced flags
	sed -i \
		-e 's/CFLAGS="-O3"//' \
		-e 's/ -rdynamic//' \
		configure || die "sed failed"
}

src_compile() {
	econf \
		$(use_enable nls i18n) \
		$(use_enable mmx mmx-optimization) \
		$(use_with png) \
		$(use_with jpeg) \
		$(use_with gif) \
		$(use_with tiff) \
		--enable-glx \
		--enable-sharedlibs \
		--with-x \
		--with-xpm \
		--without-builtin-ungif \
		--without-afterbase \
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	emake \
		DESTDIR="${D}" \
		AFTER_DOC_DIR="${ED}/usr/share/doc/${PF}" \
		install || die "emake install failed"
	dodoc ChangeLog README || die
	if use examples; then
		cd apps
		emake clean
		rm -f Makefile*
		insinto /usr/share/doc/${PF}/examples
		doins * || die "install examples failed"
	fi
}
