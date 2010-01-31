# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/xfig/xfig-3.2.5b.ebuild,v 1.7 2010/01/31 00:16:15 maekke Exp $

EAPI="2"
inherit eutils multilib

MY_P=${PN}.${PV}

DESCRIPTION="A menu-driven tool to draw and manipulate objects interactively in an X window."
HOMEPAGE="http://www.xfig.org"
SRC_URI="mirror://sourceforge/mcj/${MY_P}.full.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="x11-libs/libXaw
		x11-libs/libXp
		x11-libs/Xaw3d
		x11-libs/libXi
		media-libs/jpeg
		media-libs/libpng
		media-fonts/font-misc-misc
		media-fonts/urw-fonts
		>=media-gfx/transfig-3.2.5-r1
		media-libs/netpbm"
DEPEND="${RDEPEND}
		x11-misc/imake
		x11-proto/xproto
		x11-proto/inputproto"

S=${WORKDIR}/${MY_P}

sed_Imakefile() {
	# see Imakefile for details
	vars2subs=( BINDIR="${EPREFIX}"/usr/bin
		PNGINC=-I"${EPREFIX}"/usr/include
		JPEGLIBDIR="${EPREFIX}"/usr/$(get_libdir)
		JPEGINC=-I"${EPREFIX}"/usr/include
		XPMLIBDIR="${EPREFIX}"/usr/$(get_libdir)
		XPMINC=-I"${EPREFIX}"/usr/include/X11
		USEINLINE=-DUSE_INLINE
		XFIGLIBDIR="${EPREFIX}"/usr/share/xfig
		XFIGDOCDIR="${EPREFIX}/usr/share/doc/${PF}"
		MANDIR="${EPREFIX}/usr/share/man/man\$\(MANSUFFIX\)"
		"CC=$(tc-getCC)" )

	for variable in "${vars2subs[@]}" ; do
		varname=${variable%%=*}
		varval=${variable##*=}
		sed -i "s:^\(XCOMM\)*[[:space:]]*${varname}[[:space:]]*=.*$:${varname} = ${varval}:" "$@"
	done
	sed -i "s:^\(XCOMM\)*[[:space:]]*\(#define I18N\).*$:\2:" "$@"
	if has_version '>=x11-libs/Xaw3d-1.5e'; then
		einfo "x11-libs/Xaw3d 1.5e and abover installed"
		sed -i "s:^\(XCOMM\)*[[:space:]]*\(#define XAW3D1_5E\).*$:\2:" "$@"
	fi
}

src_prepare() {
	# Permissions are really crazy here
	chmod -R go+rX .
	find . -type f -exec chmod a-x '{}' \;
	epatch "${FILESDIR}/${P}-figparserstack.patch" #297379
	epatch "${FILESDIR}/${P}-spelling.patch"
	epatch "${FILESDIR}/${P}-papersize_b1.patch"
	epatch "${FILESDIR}/${P}-pdfimport_mediabox.patch"
	epatch "${FILESDIR}/${P}-network_images.patch"
	epatch "${FILESDIR}/${P}-app-defaults.patch"
	epatch "${FILESDIR}/${P}-zoom-during-edit.patch"
	epatch "${FILESDIR}/${P}-urwfonts.patch"
	epatch "${FILESDIR}/${P}-mkstemp.patch" #264575
	sed_Imakefile Imakefile
	sed -e "s:/usr/lib/X11/xfig:${EPREFIX}/usr/share/doc/${PF}:" \
		-i Doc/xfig.man -i Doc/xfig_man.html || die

	epatch "${FILESDIR}"/${PN}-3.2.5-darwin.patch
	epatch "${FILESDIR}"/${PN}-3.2.5-solaris.patch
}

src_compile() {
	local EXTCFLAGS=${CFLAGS}
	xmkmf || die
	[[ ${CHOST} == *-solaris* ]] && EXTCFLAGS="${EXTCFLAGS} -D_POSIX_SOURCE"
	emake CC="$(tc-getCC)" LOCAL_LDFLAGS="${LDFLAGS}" CDEBUGFLAGS="${EXTCFLAGS}" \
		USRLIBDIR="${EPREFIX}"/usr/$(get_libdir) || die
}

src_install() {
	emake -j1 DESTDIR="${D}" install.all || die

	insinto /usr/share/doc/${PF}
	doins README FIGAPPS CHANGES LATEX.AND.XFIG

	doicon xfig.png
	make_desktop_entry xfig Xfig xfig
}
