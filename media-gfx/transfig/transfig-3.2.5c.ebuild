# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/transfig/transfig-3.2.5c.ebuild,v 1.5 2010/01/31 00:17:54 maekke Exp $

EAPI="2"
inherit toolchain-funcs eutils flag-o-matic

MY_P=${PN}.${PV}

DESCRIPTION="A set of tools for creating TeX documents with graphics"
HOMEPAGE="http://www.xfig.org/"
SRC_URI="http://xfig.org/software/xfig/${PV/[a-z]}/${MY_P}.tar.gz
	mirror://gentoo/fig2mpdf-1.1.2.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="x11-libs/libXpm
	>=media-libs/jpeg-6
	media-libs/libpng
	x11-apps/rgb"
DEPEND="${RDEPEND}
	x11-misc/imake
	app-text/rman"

S=${WORKDIR}/${MY_P}

sed_Imakefile() {
	# see fig2dev/Imakefile for details
	vars2subs="BINDIR=${EPREFIX}/usr/bin
			MANDIR=${EPREFIX}/usr/share/man/man\$\(MANSUFFIX\)
			XFIGLIBDIR=${EPREFIX}/usr/share/xfig
			PNGINC=-I${EPREFIX}/usr/include/X11
			XPMINC=-I${EPREFIX}/usr/include/X11
			USEINLINE=-DUSE_INLINE
			RGB=${EPREFIX}/usr/share/X11/rgb.txt
			FIG2DEV_LIBDIR=${EPREFIX}/usr/share/fig2dev"

	for variable in ${vars2subs} ; do
		varname=${variable%%=*}
		varval=${variable##*=}
		sed -i "s:^\(XCOMM\)*[[:space:]]*${varname}[[:space:]]*=.*$:${varname} = ${varval}:" "$@"
	done
}

src_prepare() {
	find . -type f -exec chmod a-x '{}' \;
	find . -name Makefile -delete
	epatch "${FILESDIR}"/${P}-cups_workaround.patch
	epatch "${FILESDIR}"/${P}-avoid_warnings.patch
	epatch "${FILESDIR}"/${P}-fig2mpdf.patch
	epatch "${FILESDIR}"/${P}-maxfontsize.patch
	sed -e 's:-L$(ZLIBDIR) -lz::' \
		-e 's: -lX11::' \
			-i fig2dev/Imakefile || die
	epatch "${FILESDIR}"/${PN}-3.2.5-solaris.patch
	sed_Imakefile fig2dev/Imakefile fig2dev/dev/Imakefile
}

src_compile() {
	xmkmf || die "xmkmf failed"
	emake Makefiles || die "make Makefiles failed"

	if [[ ${CHOST} == *-solaris* ]] ; then
		# defining NOSTDHDRS really gets us into trouble on Solaris because it
		# triggers a problem with a redeclaration of wchar_t, so kill the flag
		sed -i -e 's/-DNOSTDHDRS//g' fig2dev/Makefile fig2dev/dev/Makefile
	fi

	emake CC="$(tc-getCC)" LOCAL_LDFLAGS="${LDFLAGS}" CDEBUGFLAGS="${CFLAGS}" \
		USRLIBDIR="${EPREFIX}"/usr/$(get_libdir) || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" \
		${transfig_conf} install install.man || die

	dobin "${WORKDIR}/fig2mpdf/fig2mpdf" || die
	doman "${WORKDIR}/fig2mpdf/fig2mpdf.1" || die

	insinto /usr/share/fig2dev/
	newins "${FILESDIR}/transfig-ru_RU.CP1251.ps" ru_RU.CP1251.ps || die
	newins "${FILESDIR}/transfig-ru_RU.KOI8-R.ps" ru_RU.KOI8-R.ps || die
	newins "${FILESDIR}/transfig-uk_UA.KOI8-U.ps" uk_UA.KOI8-U.ps || die

	dohtml "${WORKDIR}/fig2mpdf/doc/"* || die

	dodoc README CHANGES LATEX.AND.XFIG NOTES || die
}

pkg_postinst() {
	elog "Note, that defaults are changed and now if you don't want to ship"
	elog "personal information into output files, use fig2dev with -a option."
}
