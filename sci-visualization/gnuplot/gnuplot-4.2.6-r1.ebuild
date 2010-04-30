# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-visualization/gnuplot/gnuplot-4.2.6-r1.ebuild,v 1.3 2010/03/07 20:02:31 ulm Exp $

EAPI=2

inherit autotools elisp-common eutils multilib wxwidgets flag-o-matic

MY_P="${P/_/-}"
DESCRIPTION="Command-line driven interactive plotting program"
HOMEPAGE="http://www.gnuplot.info/"
SRC_URI="mirror://sourceforge/gnuplot/${MY_P}.tar.gz
	mirror://gentoo/${PN}-4.2.5-lua-term.patch.bz2"

LICENSE="gnuplot GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc emacs +gd ggi latex lua pdf plotutils readline svga wxwidgets X xemacs"
RESTRICT="wxwidgets? ( test )"

RDEPEND="
	xemacs? ( app-editors/xemacs app-xemacs/texinfo app-xemacs/xemacs-base )
	emacs? ( virtual/emacs !app-emacs/gnuplot-mode )
	pdf? ( media-libs/pdflib )
	lua? ( >=dev-lang/lua-5.1 )
	ggi? ( media-libs/libggi )
	gd? ( >=media-libs/gd-2[png] )
	latex? ( virtual/latex-base
		lua? ( dev-tex/pgf
			>=dev-texlive/texlive-latexrecommended-2008-r2 ) )
	X? ( x11-libs/libXaw )
	svga? ( media-libs/svgalib )
	readline? ( >=sys-libs/readline-4.2 )
	plotutils? ( media-libs/plotutils )
	wxwidgets? ( x11-libs/wxGTK:2.8[X]
		>=x11-libs/cairo-0.9
		>=x11-libs/pango-1.10.3
		>=x11-libs/gtk+-2.8 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? ( virtual/latex-base
		app-text/ghostscript-gpl )"

S="${WORKDIR}/${MY_P}"
E_SITEFILE="50${PN}-gentoo.el"
TEXMF="${EPREFIX}/usr/share/texmf-site"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-4.2.2-disable_texi_generation.patch #194216
	epatch "${FILESDIR}"/${PN}-4.2.3-app-defaults.patch #219323
	epatch "${FILESDIR}"/${PN}-4.2.3-disable-texhash.patch #201871
	epatch "${WORKDIR}"/${PN}-4.2.5-lua-term.patch #233475
	epatch "${FILESDIR}"/${PN}-4.2.5-configure-pkgconfig.patch #233475 c9
	# Add Gentoo version identification since the licence requires it
	epatch "${FILESDIR}"/${PN}-gentoo-version.patch

	eautoreconf
}

src_configure() {
	# the compiler explodes if you try to use AltiVec on PPC
	[[ ${CHOST} == powerpc-apple-darwin* ]] && filter-flags -faltivec

	# See bug #156427.
	if use latex ; then
		sed -i -e "s:\`kpsexpand.*\`:${TEXMF}/tex/latex/${PN}:" \
			share/LaTeX/Makefile.in || die
	else
		sed -i \
			-e '/^SUBDIRS/ s/LaTeX//' share/LaTeX/Makefile.in || die
	fi

	if use wxwidgets; then
		WX_GTK_VER="2.8"
		need-wxwidgets unicode
	fi

	local myconf
	myconf="--with-gihdir=${EPREFIX}/usr/share/${PN}/gih --without-lisp-files"
	myconf="${myconf} $(use_with X x)"
	myconf="${myconf} $(use_with svga linux-vga)"
	myconf="${myconf} $(use_with gd)"
	myconf="${myconf} $(use_enable wxwidgets)"
	myconf="${myconf} $(use_with plotutils plot "${EPREFIX}"/usr/$(get_libdir))"
	myconf="${myconf} $(use_with pdf pdf "${EPREFIX}"/usr/$(get_libdir))"
	myconf="${myconf} $(use_with lua)"
	myconf="${myconf} $(use_with doc tutorial)"
	myconf="${myconf} $(use_with latex kpsexpand)"
	myconf="${myconf} $(use_with ggi ggi ${EPREFIX}/usr/$(get_libdir))"
	myconf="${myconf} $(use_with ggi xmi ${EPREFIX}/usr/$(get_libdir))"

	use readline \
		&& myconf="${myconf} --with-readline=gnu --enable-history-file" \
		|| myconf="${myconf} --with-readline=builtin"


	econf ${myconf} CFLAGS="${CFLAGS} -DGENTOO_REVISION=\\\"${PR}\\\""

	if use xemacs; then
		einfo "Configuring gnuplot-mode for XEmacs ..."
		use emacs && cp -Rp lisp lisp-xemacs || ln -s lisp lisp-xemacs
		cd "${S}/lisp-xemacs"
		econf --with-lispdir="${EPREFIX}/usr/lib/xemacs/site-packages/${PN}" EMACS=xemacs
	fi

	if use emacs; then
		einfo "Configuring gnuplot-mode for GNU Emacs ..."
		cd "${S}/lisp"
		econf --with-lispdir="${EPREFIX}${SITELISP}/${PN}" EMACS=emacs
	fi
}

src_compile() {
	# Prevent access violations, see bug 201871
	VARTEXFONTS="${T}/fonts"

	# This is a hack to avoid sandbox violations when using the Linux console.
	# Creating the DVI and PDF tutorials require /dev/svga to build the
	# example plots.
	addwrite /dev/svga:/dev/mouse:/dev/tts/0

	emake || die

	if use xemacs; then
		cd "${S}/lisp-xemacs"
		emake || die
	fi

	if use emacs; then
		cd "${S}/lisp"
		emake || die
	fi

	if use doc; then
		# Avoid sandbox violation in epstopdf/ghostscript
		addpredict /var/cache/fontconfig
		cd "${S}/docs"
		emake pdf || die
		cd "${S}/tutorial"
		emake pdf || die

		if use xemacs || use emacs; then
			cd "${S}/lisp"
			emake pdf || die
		fi
	fi
}

src_install () {
	emake DESTDIR="${D}" install || die

	if ! use X; then
		# see bug 194527
		rm -rf "${ED}/usr/$(get_libdir)/X11"
	fi

	if use xemacs; then
		cd "${S}/lisp-xemacs"
		emake DESTDIR="${D}" install || die
	fi

	if use emacs; then
		cd "${S}/lisp"
		emake DESTDIR="${D}" install || die
		# info-look* is included with >=emacs-21
		rm -f "${ED}${SITELISP}/${PN}"/info-look*

		# Gentoo emacs site-lisp configuration
		echo "(add-to-list 'load-path \"@SITELISP@\")" > ${E_SITEFILE}
		sed '/^;; move/,+3 d' dotemacs >> ${E_SITEFILE} || die
		elisp-site-file-install ${E_SITEFILE} || die
	fi

	cd "${S}"
	if use latex && use lua; then
		# install style file in an (additional) place where TeX can find it
		insinto "${TEXMF#${EPREFIX}}/tex/latex/${PN}"
		doins term/lua/gnuplot-lua-tikz.sty || die
	fi

	dodoc BUGS ChangeLog FAQ NEWS PATCHLEVEL PGPKEYS PORTING README* \
		TODO VERSION
	use lua && newdoc term/lua/README README-lua

	if use doc; then
		# Demo files
		insinto /usr/share/${PN}/demo
		doins demo/*
		# Manual
		dodoc docs/gnuplot.pdf
		# Tutorial
		dodoc tutorial/{tutorial.dvi,tutorial.pdf}
		# Documentation for making PostScript files
		docinto psdoc
		dodoc docs/psdoc/{*.doc,*.tex,*.ps,*.gpi,README}
	fi

	if use xemacs || use emacs; then
		docinto emacs
		dodoc lisp/ChangeLog lisp/README
		use doc && dodoc lisp/gpelcard.pdf
	fi
}

pkg_postinst() {
	use emacs && elisp-site-regen
	use latex && texmf-update

	if use svga; then
		einfo "In order to enable ordinary users to use SVGA console graphics"
		einfo "gnuplot needs to be set up as setuid root.  Please note that"
		einfo "this is usually considered to be a security hazard."
		einfo "As root, manually \"chmod u+s /usr/bin/gnuplot\"."
	fi
	if use gd; then
		echo
		einfo "For font support in png/jpeg/gif output, you may have to"
		einfo "set the GDFONTPATH and GNUPLOT_DEFAULT_GDFONT environment"
		einfo "variables. See the FAQ file in /usr/share/doc/${PF}/"
		einfo "for more information."
	fi
}

pkg_postrm() {
	use emacs && elisp-site-regen
	use latex && texmf-update
}
