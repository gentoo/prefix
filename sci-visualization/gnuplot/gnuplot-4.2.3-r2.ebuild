# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-visualization/gnuplot/gnuplot-4.2.3-r2.ebuild,v 1.7 2008/06/04 20:30:15 ken69267 Exp $

EAPI="prefix"

inherit autotools elisp-common eutils multilib wxwidgets flag-o-matic

MY_P="${P/_/.}"

DESCRIPTION="Command-line driven interactive plotting program"
HOMEPAGE="http://www.gnuplot.info/"
SRC_URI="mirror://sourceforge/gnuplot/${MY_P}.tar.gz"

LICENSE="gnuplot"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="doc emacs gd ggi latex pdf plotutils readline svga wxwindows X xemacs"
RESTRICT="wxwindows? ( test )"

RDEPEND="
	xemacs? ( virtual/xemacs app-xemacs/texinfo app-xemacs/xemacs-base )
	emacs? ( virtual/emacs !app-emacs/gnuplot-mode )
	pdf? ( media-libs/pdflib )
	ggi? ( media-libs/libggi )
	gd? ( >=media-libs/gd-2 )
	doc? ( virtual/latex-base
		virtual/ghostscript )
	latex? ( virtual/latex-base )
	X? ( x11-libs/libXaw )
	svga? ( media-libs/svgalib )
	readline? ( >=sys-libs/readline-4.2 )
	plotutils? ( media-libs/plotutils )
	wxwindows? ( =x11-libs/wxGTK-2.6*
		>=x11-libs/cairo-0.9
		>=x11-libs/pango-1.10.3
		>=x11-libs/gtk+-2.8 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S=${WORKDIR}/${MY_P}

E_SITEFILE="50gnuplot-gentoo.el"

latex_rehash() {
	if has_version '>=app-text/tetex-3' || has_version '>=app-text/ptex-3.1.8' || has_version 'app-text/texlive'; then
		texmf-update
	else
		texconfig rehash
	fi
}

pkg_setup() {
	if use gd && ! built_with_use media-libs/gd png; then
		eerror "media-libs/gd needs to be built with PNG support"
		die "please rebuilt media-libs/gd with USE=png"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	# not sane enough for upstream, but we will keep it
	epatch "${FILESDIR}"/${PN}-4.2.0-libggi.patch
	# Texinfo source is already shipped, so separate preparation not needed
	# and error-prone, see bug 194216
	epatch "${FILESDIR}"/${PN}-4.2.2-disable_texi_generation.patch
	# Don't store resource files in deprecated location, reported upstream:
	# http://sourceforge.net/tracker/index.php?func=detail&aid=1953742&group_id=2055&atid=102055
	epatch "${FILESDIR}"/${P}-app-defaults.patch

	eautoreconf
}

src_compile() {
	# the compiler explodes if you try to use AltiVec on PPC
	[[ ${CHOST} == powerpc-apple-darwin* ]] && filter-flags -faltivec

	# Prevent access violations, see bug 201871
	VARTEXFONTS="${T}/fonts"

	# See bug #156427.
	if use latex ; then
		sed -i \
			-e 's/TEXMFLOCAL/TEXMFSITE/g' share/LaTeX/Makefile.in || die
	else
		sed -i \
			-e '/^SUBDIRS/ s/LaTeX//' share/LaTeX/Makefile.in || die
	fi

	if use wxwindows ; then
		WX_GTK_VER="2.6"
		need-wxwidgets unicode
	fi

	local myconf="--with-gihdir=${EPREFIX}/usr/share/${PN}/gih"

	myconf="${myconf} $(use_with X x)"
	myconf="${myconf} $(use_with svga linux-vga)"
	myconf="${myconf} $(use_with gd)"
	myconf="${myconf} $(use_enable wxwindows wxwidgets)"
	myconf="${myconf} $(use_with plotutils plot "${EPREFIX}"/usr/$(get_libdir))"
	myconf="${myconf} $(use_with pdf pdf "${EPREFIX}"/usr/$(get_libdir))"

	use ggi \
		&& myconf="${myconf} --with-ggi=${EPREFIX}/usr/$(get_libdir)
		--with-xmi=${EPREFIX}/usr/$(get_libdir)" \
		|| myconf="${myconf} --without-ggi"

	use readline \
		&& myconf="${myconf} --with-readline=gnu --enable-history-file" \
		|| myconf="${myconf} --with-readline"

	myconf="${myconf} --without-lisp-files"

	# This is a hack to avoid sandbox violations when using the Linux console.
	# Creating the DVI and PDF tutorials require /dev/svga to build the
	# example plots.
	addwrite /dev/svga:/dev/mouse:/dev/tts/0

	TEMACS=no
	use xemacs && TEMACS=xemacs
	use emacs && TEMACS=emacs
	EMACS=${TEMACS} econf ${myconf} || die
	emake || die

	if use doc ; then
		cd docs
		emake pdf || die
		cd ../tutorial
		emake pdf || die
	fi
}

src_install () {
	emake DESTDIR="${D}" install || die

	if use emacs; then
		cd lisp
		einfo "Configuring gnuplot-mode for GNU Emacs..."
		EMACS="emacs" econf --with-lispdir="${ESITELISP}/${PN}" || die
		emake DESTDIR="${D}" install || die
		emake clean
		cd ..

		# Gentoo emacs site-lisp configuration
		string="(add-to-list 'load-path \"${EPREFIX}/usr/share/emacs/site-lisp/${PN}\")"
		echo -e ";;; Gnuplot site-lisp configuration\n\n${string}\n" > ${E_SITEFILE}
		sed '/^;; move/,+4 d' lisp/dotemacs >> ${E_SITEFILE}
		elisp-site-file-install ${E_SITEFILE}
	fi

	if use xemacs; then
		cd lisp
		einfo "Configuring gnuplot-mode for XEmacs..."
		EMACS="xemacs" econf --with-lispdir="${EPREFIX}/usr/lib/xemacs/site-packages/${PN}" || die
		emake DESTDIR="${D}" install || die
		cd ..
	fi

	dodoc BUGS ChangeLog FAQ NEWS PATCHLEVEL PGPKEYS PORTING README* TODO VERSION

	if use doc; then
		# Demo files
		insinto /usr/share/${PN}/demo
		doins demo/*
		# Manual
		insinto /usr/share/doc/${PF}/manual
		doins docs/gnuplot.pdf
		# Tutorial
		insinto /usr/share/doc/${PF}/tutorial
		doins tutorial/{tutorial.dvi,tutorial.pdf}
		# Documentation for making PostScript files
		insinto /usr/share/doc/${PF}/psdoc
		doins docs/psdoc/{*.doc,*.tex,*.ps,*.gpi,README}
	fi

	if ! use X; then
		# see bug 194527
		rm -rf "${ED}/usr/$(get_libdir)/X11"
	fi
}

pkg_postinst() {
	use emacs && elisp-site-regen
	if use svga ; then
		einfo "In order to enable ordinary users to use SVGA console graphics"
		einfo "gnuplot needs to be set up as setuid root.  Please note that"
		einfo "this is usually considered to be a security hazard."
		einfo "As root, manually \"chmod u+s /usr/bin/gnuplot\"."
	fi
	use latex && latex_rehash
}

pkg_postrm() {
	use emacs && elisp-site-regen
	use latex && latex_rehash
}
