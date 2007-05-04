# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/transfig/transfig-3.2.5.ebuild,v 1.2 2007/04/02 15:17:06 pva Exp $

EAPI="prefix"

inherit toolchain-funcs eutils flag-o-matic

MY_P=${PN}.${PV}

DESCRIPTION="A set of tools for creating TeX documents with graphics which can be printed in a wide variety of environments"
SRC_URI="http://xfig.org/software/xfig/${PV}/${MY_P}.tar.gz"
HOMEPAGE="http://www.xfig.org"
IUSE=""

SLOT="0"
LICENSE="BSD"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"

RDEPEND="|| ( x11-libs/libXpm virtual/x11 )
	>=media-libs/jpeg-6
	media-libs/libpng"
DEPEND="${RDEPEND}
	|| ( ( x11-misc/imake
			app-text/rman
		)
		virtual/x11
	)"

S="${WORKDIR}"/${MY_P}

sed_Imakefile() {
	# see fig2dev/Imakefile for details
	vars2subs="BINDIR=${EPREFIX}/usr/bin
			MANDIR=${EPREFIX}/usr/share/man/man\$\(MANSUFFIX\)
			XFIGLIBDIR=${EPREFIX}/usr/$(get_libdir)/xfig
			USEINLINE=-DUSE_INLINE
			RGB=${EPREFIX}/usr/share/X11/rgb.txt
			FIG2DEV_LIBDIR=${EPREFIX}/usr/$(get_libdir)/fig2dev"

	for variable in ${vars2subs} ; do
		varname=${variable%%=*}
		varval=${variable##*=}
		sed -i "s:^\(XCOMM\)*[[:space:]]*${varname}[[:space:]]*=.*$:${varname} = ${varval}:" "$@"
	done
}

src_compile() {
	sed_Imakefile fig2dev/Imakefile fig2dev/dev/Imakefile

	# without append transfig compiles with warining
	# incompatible implicit declaration of built-in function âstrlenâ
	# but are we really SVR4?
	#append-flags -DSVR4
	xmkmf || die "xmkmf failed"
	make Makefiles || die "make Makefiles failed"

	emake CC="$(tc-getCC)" LOCAL_LDFLAGS="${LDFLAGS}" CDEBUGFLAGS="${CFLAGS}" \
	USRLIBDIR="${EPREFIX}"/usr/$(get_libdir) || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" \
		${transfig_conf} install install.man || die

	#Install docs
	dodoc README CHANGES LATEX.AND.XFIG NOTES
}
