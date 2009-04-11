# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/transfig/transfig-3.2.5-r1.ebuild,v 1.1 2008/05/11 12:04:31 pva Exp $

inherit toolchain-funcs eutils flag-o-matic

MY_P=${PN}.${PV}

DESCRIPTION="A set of tools for creating TeX documents with graphics which can be printed in a wide variety of environments"
SRC_URI="http://xfig.org/software/xfig/${PV}/${MY_P}.tar.gz"
HOMEPAGE="http://www.xfig.org"
IUSE=""

SLOT="0"
LICENSE="BSD"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"

RDEPEND="x11-libs/libXpm
	>=media-libs/jpeg-6
	media-libs/libpng"
DEPEND="${RDEPEND}
	x11-misc/imake
	app-text/rman"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"

	find "${S}" -type f -exec chmod -x \{\} \;
}

sed_Imakefile() {
	# see fig2dev/Imakefile for details
	vars2subs="BINDIR=${EPREFIX}/usr/bin
			MANDIR=${EPREFIX}/usr/share/man/man\$\(MANSUFFIX\)
			XFIGLIBDIR=${EPREFIX}/usr/share/xfig
			USEINLINE=-DUSE_INLINE
			RGB=${EPREFIX}/usr/share/X11/rgb.txt
			FIG2DEV_LIBDIR=${EPREFIX}/usr/share/fig2dev"

	for variable in ${vars2subs} ; do
		varname=${variable%%=*}
		varval=${variable##*=}
		sed -i "s:^\(XCOMM\)*[[:space:]]*${varname}[[:space:]]*=.*$:${varname} = ${varval}:" "$@"
	done
}

src_compile() {
	sed_Imakefile fig2dev/Imakefile fig2dev/dev/Imakefile

	xmkmf || die "xmkmf failed"
	make Makefiles || die "make Makefiles failed"

	if [[ ${CHOST} == *-solaris* ]] ; then
		# defining NOSTDHDRS really gets us into trouble on Solaris because it
		# triggers a problem with a redeclaration of wchar_t, so kill the flag
		sed -i -e 's/-DNOSTDHDRS//g' fig2dev/Makefile fig2dev/dev/Makefile
	fi

	emake CC="$(tc-getCC)" LOCAL_LDFLAGS="${LDFLAGS}" CDEBUGFLAGS="${CFLAGS}" \
	USRLIBDIR="${EPREFIX}"/usr/$(get_libdir) || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" \
		${transfig_conf} install install.man || die

	#Install docs
	dodoc README CHANGES LATEX.AND.XFIG NOTES
}
