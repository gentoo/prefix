# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/asymptote/asymptote-1.72.ebuild,v 1.1 2009/05/16 15:02:05 grozin Exp $
EAPI=2
inherit eutils autotools elisp-common latex-package multilib python

DESCRIPTION="A vector graphics language that provides a framework for technical drawing"
HOMEPAGE="http://asymptote.sourceforge.net/"
SRC_URI="mirror://sourceforge/asymptote/${P}.src.tgz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="+boehm-gc doc emacs examples fftw gsl +imagemagick latex python sigsegv vim-syntax X"

RDEPEND=">=sys-libs/readline-4.3-r5
	>=sys-libs/ncurses-5.4-r5
	imagemagick? ( media-gfx/imagemagick[png] )
	sigsegv? ( dev-libs/libsigsegv )
	boehm-gc? ( >=dev-libs/boehm-gc-7.0[-nocxx,threads] )
	fftw? ( >=sci-libs/fftw-3.0.1 )
	gsl? ( sci-libs/gsl )
	X? ( x11-misc/xdg-utils dev-lang/python dev-python/imaging[tk] )
	python? ( dev-lang/python )
	latex? ( virtual/latex-base )
	emacs? ( virtual/emacs )
	vim-syntax? ( || ( app-editors/vim app-editors/gvim ) )
	virtual/opengl
	media-libs/freeglut"
DEPEND="${RDEPEND}
	doc? ( dev-lang/perl virtual/texi2dvi virtual/latex-base media-gfx/imagemagick[png] )"

TEXMF=/usr/share/texmf-site

src_prepare() {
	# Fixing fftwl, gsl, sigsegv enabling
	epatch "${FILESDIR}/${P}-configure-ac.patch"
	einfo "Patching configure.ac"
	sed -e "s:Datadir/doc/asymptote:Datadir/doc/${PF}:" \
		-i configure.ac \
		|| die "sed configure.ac failed"

	# Changing pdf, ps, image viewers to xdg-open
	epatch "${FILESDIR}/${P}-xdg-utils.patch"

	# see if this is still necessary: epatch "${FILESDIR}"/${PN}-1.49-darwin.patch

	eautoreconf
}

src_configure() {
	# for the CPPFLAGS see
	# http://sourceforge.net/forum/forum.php?thread_id=1683277&forum_id=409349
	econf CPPFLAGS=-DHAVE_SYS_TYPES_H \
		--disable-gc-debug \
		$(use_enable boehm-gc gc system) \
		$(use_with fftw) \
		$(use_with gsl) \
		$(use_with sigsegv)
}

src_compile() {
	emake || die "emake failed"

	cd doc
	emake asy.1 || die "emake asy.1 failed"
	if use doc; then
		# info
		einfo "Making info"
		emake ${PN}.info || die "emake ${PN}.info failed"
		# html
		einfo "Making html docs"
		emake ${PN}/index.html
		einfo "Making FAQ"
		cd FAQ
		emake
		cd ..
		# pdf
		einfo "Making pdf docs"
		export VARTEXFONTS="${T}"/fonts
		# see bug #260606
		emake -j1 asymptote.pdf
		emake CAD.pdf
	fi
	cd ..

	if use emacs; then
		einfo "Compiling emacs lisp files"
		elisp-compile base/*.el || die "elisp-compile failed"
	fi
}

src_install() {
	# the program
	exeinto /usr/bin
	doexe asy

	# .asy files
	insinto /usr/share/${PN}
	doins base/*.asy

	# documentation
	dodoc BUGS ChangeLog README ReleaseNotes TODO
	doman doc/asy.1

	# X GUI
	if use X; then
		exeinto /usr/share/${PN}/GUI
		doexe GUI/xasy.py
		rm GUI/xasy.py
		insinto /usr/share/${PN}/GUI
		doins GUI/*.py
		dosym /usr/share/${PN}/GUI/xasy.py /usr/bin/xasy
		doman doc/xasy.1x
	fi

	# examples
	if use examples; then
		insinto /usr/share/${PN}/examples
		doins examples/*.asy \
			examples/*.eps \
			doc/*.asy \
			doc/*.csv \
			doc/*.dat \
			doc/extra/*.asy
		if use X; then
			doins GUI/*.asy
		fi
		insinto /usr/share/${PN}/examples/animations
		doins examples/animations/*.asy
	fi

	# LaTeX style
	if use latex; then
		cd doc
		insinto "${TEXMF}"/tex/latex/${PN}
		doins ${PN}.sty asycolors.sty
		if use examples; then
			insinto /usr/share/${PN}/examples
			doins latexusage.tex
		fi
		cd ..
	fi

	# asymptote.py
	if use python; then
		python_version
		insinto /usr/$(get_libdir)/python${PYVER}/site-packages
		doins base/${PN}.py
	fi

	# emacs mode
	if use emacs; then
		elisp-install ${PN} base/*.el base/*.elc
		elisp-site-file-install "${FILESDIR}"/64${PN}-gentoo.el
	fi

	# vim syntax
	if use vim-syntax; then
		insinto /usr/share/vim/vimfiles/syntax
		doins base/asy.vim
		insinto /usr/share/vim/vimfiles/ftdetect
		doins "${FILESDIR}"/asy-ftd.vim
	fi

	# extra documentation
	if use doc; then
		cd doc
		doinfo ${PN}.info*
		dohtml ${PN}/*
		cd FAQ
		dodoc asy-faq.ascii
		doinfo asy-faq.info
		insinto /usr/share/doc/${PF}/html/FAQ
		doins asy-faq.html/*
		cd ..
		insinto /usr/share/doc/${PF}
		doins ${PN}.pdf CAD.pdf
	fi
}

pkg_postinst() {
	if use python; then
		python_version
		python_mod_compile \
			/usr/$(get_libdir)/python${PYVER}/site-packages/${PN}.py
	fi

	use latex && latex-package_rehash

	use emacs && elisp-site-regen

	elog 'Use the variable ASYMPTOTE_PSVIEWER to set the postscript viewer'
	elog 'Use the variable ASYMPTOTE_PDFVIEWER to set the PDF viewer'
}

pkg_postrm() {
	use latex && latex-package_rehash
	use emacs && elisp-site-regen
	use python && python_mod_cleanup
}
