# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-tex/luatex/luatex-0.30.3.ebuild,v 1.12 2009/05/23 09:50:55 aballier Exp $

EAPI="2"

inherit libtool multilib eutils toolchain-funcs

PATCHLEVEL="10"

DESCRIPTION="An extended version of pdfTeX using Lua as an embedded scripting language."
HOMEPAGE="http://www.luatex.org/"
SRC_URI="http://foundry.supelec.fr/frs/download.php/699/${PN}-beta-${PV}.tar.bz2
	mirror://gentoo/${PN}-patches-${PATCHLEVEL}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc"

RDEPEND="dev-tex/mplib[lua]
	dev-libs/zziplib
	media-libs/libpng
	virtual/poppler
	sys-libs/zlib"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S="${WORKDIR}/${PN}-beta-${PV}/src"

src_prepare() {
	EPATCH_SUFFIX="patch" epatch "${WORKDIR}/patches"
	elibtoolize
	if [[ ${CHOST} == *-solaris* ]] ; then
		# very stupid workaround for a totally wicked buildsystem
		# we need -lresolv for hstrerror
		cd "${S}"
		sed -i -e '/^socketlibs = /s/^.*$/& -lresolv/' \
			texk/web2c/Makefile.in || die
	fi
}

src_configure() {
	# Too many regexps use A-Z a-z constructs, what causes problems with locales
	# that don't have the same alphabetical order than ascii. Bug #244619
	# So we set LC_ALL to C in order to avoid problems.
	export LC_ALL=C
	tc-export CC CXX AR RANLIB
	export NATIVE='.'
	mkdir -p "${WORKDIR}/${PN}-beta-${PV}/build"
	cd "${WORKDIR}/${PN}-beta-${PV}/build"
	ECONF_SOURCE="${S}" econf \
		--without-cxx-runtime-hack \
		--without-aleph     \
		--without-bibtex8   \
		--without-cjkutils  \
		--without-detex     \
		--without-dialog    \
		--without-dtl       \
		--without-dvi2tty   \
		--without-dvidvi    \
		--without-dviljk    \
		--without-dvipdfm   \
		--without-dvipdfmx  \
		--without-dvipng    \
		--without-dvipos    \
		--without-dvipsk    \
		--without-etex      \
		--without-gsftopk   \
		--without-lacheck   \
		--without-lcdf-typetools  \
		--without-makeindexk      \
		--without-mkocp-default   \
		--without-mkofm-default   \
		--without-musixflx  \
		--without-omega     \
		--without-pdfopen   \
		--without-ps2eps    \
		--without-ps2pkm    \
		--without-psutils   \
		--without-sam2p     \
		--without-seetexk   \
		--without-t1utils   \
		--without-tetex     \
		--without-tex4htk   \
		--without-texi2html \
		--without-texinfo   \
		--without-texlive   \
		--without-ttf2pk    \
		--without-tth       \
		--without-xdv2pdf   \
		--without-xdvik     \
		--without-xdvipdfmx \
		--without-xetex     \
		--disable-largefile \
		--with-system-zlib \
		--with-system-pnglib
}

src_compile() {
	cd "${WORKDIR}/${PN}-beta-${PV}/build/texk/web2c"
	emake \
		LIBMPLIBDEP="${EPREFIX}/usr/$(get_libdir)/libmplib/mplib.a" \
		LDZZIPLIB="$(pkg-config --libs zziplib)" ZZIPLIBINC="$(pkg-config --cflags zziplib)" \
		LIBXPDFDEP="" LDLIBXPDF="$(pkg-config --libs poppler)" \
		LIBXPDFINCLUDE="$(pkg-config --cflags poppler)"	LIBXPDFCPPFLAGS="$(pkg-config --cflags poppler)" \
		LIBPNGINCLUDES="$(pkg-config --cflags libpng)" \
		ZLIBSRCDIR="." \
		ARFLAGS="rcs" \
		luatex || die "failed to build luatex"
}

src_install() {
	cd "${WORKDIR}/${PN}-beta-${PV}/build/texk/web2c"
	emake bindir="${ED}/usr/bin" \
		LIBMPLIBDEP="${EPREFIX}/usr/$(get_libdir)/libmplib/mplib.a" \
		LDZZIPLIB="$(pkg-config --libs zziplib)" ZZIPLIBINC="$(pkg-config --cflags zziplib)" \
		LIBXPDFDEP="" LDLIBXPDF="$(pkg-config --libs poppler)" \
		LIBXPDFINCLUDE="$(pkg-config --cflags poppler)"	LIBXPDFCPPFLAGS="$(pkg-config --cflags poppler)" \
		LIBPNGINCLUDES="$(pkg-config --cflags libpng)" \
		ZLIBSRCDIR="." \
		install-luatex || die "install-luatex failed"

	dodoc "${WORKDIR}/${PN}-beta-${PV}/README"
	if use doc ; then
		insinto /usr/share/doc/${PF}
		doins "${WORKDIR}/${PN}-beta-${PV}/manual/"*.pdf
	fi
}

pkg_postinst() {
	if ! has_version '>=dev-texlive/texlive-basic-2008' ; then
		elog "Please note that this package does not install much files, mainly the"
		elog "${PN} executable that will need other files in order to be useful.."
		elog "Please consider installing a recent TeX distribution"
		elog "like TeX Live 2008 to get the full power of ${PN}"
	fi
	if [ "$ROOT" = "/" ] && [ -x "${EPREFIX}"/usr/bin/fmtutil-sys ] ; then
		einfo "Rebuilding formats"
		"${EPREFIX}"/usr/bin/fmtutil-sys --all &> /dev/null
	else
		ewarn "Cannot run fmtutil-sys for some reason."
		ewarn "Your formats might be inconsistent with your installed ${PN} version"
		ewarn "Please try to figure what has happened"
	fi
}
