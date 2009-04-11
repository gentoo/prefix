# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/xfig/xfig-3.2.5-r2.ebuild,v 1.1 2008/05/11 12:09:54 pva Exp $

inherit eutils multilib

MY_P=${PN}.${PV}
DESCRIPTION="A menu-driven tool to draw and manipulate objects interactively in an X window."
HOMEPAGE="http://www.xfig.org"
SRC_URI="http://www.xfig.org/software/xfig/3.2.5/${MY_P}.full.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

RDEPEND="x11-libs/libXaw
		x11-libs/libXp
		x11-libs/Xaw3d
		media-libs/jpeg
		media-libs/libpng
		>=media-gfx/transfig-3.2.5-r1
		media-libs/netpbm"
DEPEND="${RDEPEND}
		x11-misc/imake
		app-text/rman
		x11-proto/xproto
		x11-proto/inputproto
		x11-libs/libXi"

S="${WORKDIR}"/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# We do not have nescape. Let's use firefox instead...
	sed -i "s+netscape+firefox+g" Fig.ad
	find "${S}" -type f -exec chmod -x \{\} \;

	epatch "${FILESDIR}"/${P}-darwin.patch
}

sed_Imakefile() {
	# see Imakefile for details
	vars2subs="BINDIR=${EPREFIX}/usr/bin
		PNGINC=-I${EPREFIX}/usr/include
		JPEGLIBDIR=${EPREFIX}/usr/$(get_libdir)
		JPEGINC=-I${EPREFIX}/usr/include
		XPMLIBDIR=${EPREFIX}/usr/$(get_libdir)
		XPMINC=-I${EPREFIX}/usr/include/X11
		USEINLINE=-DUSE_INLINE
		XFIGLIBDIR=${EPREFIX}/usr/share/xfig
		XFIGDOCDIR=${EPREFIX}/usr/share/doc/${P}
		MANDIR=${EPREFIX}/usr/share/man/man\$\(MANSUFFIX\)
		CC=$(tc-getCC)"

	for variable in ${vars2subs} ; do
		varname=${variable%%=*}
		varval=${variable##*=}
		sed -i "s:^\(XCOMM\)*[[:space:]]*${varname}[[:space:]]*=.*$:${varname} = ${varval}:" "$@"
	done
}

src_compile() {
	sed_Imakefile Imakefile

	xmkmf || die
	emake CC="$(tc-getCC)" LOCAL_LDFLAGS="${LDFLAGS}" CDEBUGFLAGS="${CFLAGS}" \
	USRLIBDIR="${EPREFIX}"/usr/$(get_libdir) || die
}

src_install() {
	emake -j1 DESTDIR="${D}" install.all || die

	insinto /usr/share/doc/${P}
	doins README FIGAPPS CHANGES LATEX.AND.XFIG
}
