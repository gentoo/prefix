# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/tiff/tiff-3.8.2-r6.ebuild,v 1.2 2009/06/23 08:23:12 flameeyes Exp $

EAPI="2"

inherit eutils libtool multilib

DESCRIPTION="Library for manipulation of TIFF (Tag Image File Format) images"
HOMEPAGE="http://www.remotesensing.org/libtiff/"
SRC_URI="ftp://ftp.remotesensing.org/pub/libtiff/${P}.tar.gz
	mirror://gentoo/${P}-pdfsec-patches.tar.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="jpeg jbig nocxx opengl zlib"

RDEPEND="jpeg? ( >=media-libs/jpeg-6b )
	jbig? ( >=media-libs/jbigkit-1.6-r1 )
	zlib? ( >=sys-libs/zlib-1.1.3-r2 )
	opengl? ( media-libs/mesa
		x11-libs/libX11
		x11-libs/libXmu
		x11-libs/libXt
		x11-libs/libSM
		x11-libs/libICE
		x11-libs/libXi
		x11-libs/libXxf86vm
		x11-libs/libXext
		x11-libs/libxcb
		x11-libs/libXau
		x11-libs/libXdmcp )"

DEPEND="${RDEPEND}
	opengl? ( app-admin/eselect-opengl
		sys-devel/gcc[objc]
		x11-proto/xproto
		x11-proto/xcb-proto
		x11-proto/xextproto
		x11-proto/xf86vidmodeproto
		x11-proto/glproto )"

src_prepare() {
#	unpack ${A}
#	cd "${S}"
	epatch "${WORKDIR}"/${P}-tiff2pdf-20080903.patch
	epatch "${FILESDIR}"/${P}-tiffsplit.patch
	use jbig && epatch "${FILESDIR}"/${PN}-jbig.patch
	epatch "${WORKDIR}"/${P}-goo-sec.patch
	epatch "${FILESDIR}"/${P}-CVE-2008-2327.patch
	use opengl && epatch "${FILESDIR}"/${P}-opengl.patch
	elibtoolize

	if use opengl; then
		sed -i -e "s|-framework GLUT|-lGLU -lGL -lglut -L${EPREFIX}/usr/$(get_libdir)|g" \
			configure || die "sed 2 failed"
	fi
}

src_compile() {
	if use opengl; then
		myconf="--with-x --with-apple-opengl-framework"
	else
		myconf="--without-x"
	fi

	econf \
		$(use_enable !nocxx cxx) \
		$(use_enable zlib) \
		$(use_enable jpeg) \
		$(use_enable jbig) \
		${myconf} --with-pic \
		--with-docdir="${EPREFIX}"/usr/share/doc/${PF} \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make install DESTDIR="${D}" || die "make install failed"
	dodoc README TODO VERSION
}

pkg_postinst() {
	echo
	elog "JBIG support is intended for Hylafax fax compression, so we"
	elog "really need more feedback in other areas (most testing has"
	elog "been done with fax).  Be sure to recompile anything linked"
	elog "against tiff if you rebuild it with jbig support."
	echo
	elog "Opengl support also pulls in several X libraries; since it"
	elog "hasn't been used much recently, it should be considered"
	elog "somewhat experimental until more testing and feedback."
	echo
}
