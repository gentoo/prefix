# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/asymptote/asymptote-1.43.ebuild,v 1.3 2008/07/08 10:35:25 grozin Exp $

EAPI="prefix"

inherit eutils autotools elisp-common latex-package multilib python

DESCRIPTION="A vector graphics language that provides a framework for technical drawing"
HOMEPAGE="http://asymptote.sourceforge.net/"
SRC_URI="mirror://sourceforge/asymptote/${P}.src.tgz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"

IUSE="boehm-gc doc emacs examples fftw gsl latex python vim-syntax X"

RDEPEND=">=sys-libs/readline-4.3-r5
	>=sys-libs/ncurses-5.4-r5
	dev-libs/libsigsegv
	x11-misc/xdg-utils
	boehm-gc? ( >=dev-libs/boehm-gc-7.0 )
	fftw? ( >=sci-libs/fftw-3.0.1 )
	gsl? ( sci-libs/gsl )
	X? ( dev-lang/python dev-python/imaging )
	python? ( dev-lang/python )
	latex? ( virtual/latex-base )
	emacs? ( virtual/emacs )
	vim-syntax? ( || ( app-editors/vim app-editors/gvim ) )"
DEPEND="${RDEPEND}
	doc? ( dev-lang/perl virtual/texi2dvi )"

pkg_setup() {
	# checking if Boehm garbage collector was compiled with c++ support
	if use boehm-gc; then
		if ! built_with_use dev-libs/boehm-gc nocxx; then
			einfo "dev-libs/boehm-gc has been compiled with nocxx use flag disabled"
		else
			echo
			eerror "You have to rebuild dev-libs/boehm-gc enabling c++ support"
			die
		fi
	fi

	if use X && ! built_with_use dev-python/imaging tk; then
		eerror "Please re-emerge dev-python/imaging with the USE flag 'tk'"
		die "Missing USE flag 'tk' for dev-python/imaging"
	fi

	if use latex; then
		# Calculating ASY_TEXMFDIR
		local TEXMFPATH="$(kpsewhich -var-value=TEXMFSITE)"
		local TEXMFCONFIGFILE="$(kpsewhich texmf.cnf)"

		if [ -z "${TEXMFPATH}" ]; then
			eerror "You haven't defined the TEXMFSITE variable in your TeX config."
			eerror "Please do so in the file ${TEXMFCONFIGFILE:-/var/lib/texmf/web2c/texmf.cnf}"
			die "Define TEXMFSITE in TeX configuration!"
		else
			# go through the colon separated list of directories
			# (maybe only one) provided in the variable
			# TEXMFPATH (generated from TEXMFSITE from TeX's config)
			# and choose only the first entry.
			# All entries are separated by colons, even when defined
			# with semi-colons, kpsewhich changes
			# the output to a generic format, so IFS has to be redefined.
			local IFS="${IFS}:"

			for strippedpath in ${TEXMFPATH}; do
				if [ -d ${strippedpath} ]; then
					ASY_TEXMFDIR="${strippedpath}"
					break
				fi
			done

			# verify if an existing path was chosen to prevent from
			# installing into the wrong directory
			if [ -z ${ASY_TEXMFDIR} ]; then
				eerror "TEXMFSITE does not contain any existing directory."
				eerror "Please define an existing directory in your TeX config file"
				eerror "${TEXMFCONFIGFILE:-/var/lib/texmf/web2c/texmf.cnf} or create at least one of the there specified directories"
				die "TEXMFSITE variable did not contain an existing directory"
			fi
		fi
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fixing fftw and gsl enabling
	epatch "${FILESDIR}/${P}-configure-ac.patch"
	einfo "Patching configure.ac"
	sed -e "s:Datadir/doc/asymptote:Datadir/doc/${PF}:" \
		-i configure.ac \
		|| die "sed configure.ac failed"

	# Changing pdf, ps, image viewers to xdg-open
	epatch "${FILESDIR}/${P}-xdg-utils.patch"

	eautoreconf
}

src_compile() {
	# for the CPPFLAGS see
	# http://sourceforge.net/forum/forum.php?thread_id=1683277&forum_id=409349
	local myconf="--disable-gc-debug CPPFLAGS=-DHAVE_SYS_TYPES_H"

	if use boehm-gc; then
		myconf="${myconf} --enable-gc=system"
	else
		myconf="${myconf} --disable-gc"
	fi

	econf ${myconf} \
		$(use_with fftw) \
		$(use_with gsl) \
		|| die "econf failed"

	emake || die "emake failed"

	cd doc
	emake asy.1 || die "emake asy.1 failed"
	emake ${PN}.info || die "emake ${PN}.info failed"
	if use doc; then
		einfo "Making html docs"
		emake ${PN}/index.html
		einfo "Making FAQ"
		cd FAQ
		emake
		cd ..
		# pdf files
		einfo "Making pdf docs"
		export VARTEXFONTS="${T}"/fonts
		emake asymptote.pdf
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
	cd doc
	doman asy.1
	doinfo ${PN}.info*
	cd ..

	# X GUI
	if use X; then
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
		insinto /usr/share/${PN}/examples/animations
		doins examples/animations/*.asy
	fi

	# LaTeX style
	if use latex; then
		cd doc
		insinto "${ASY_TEXMFDIR}"/tex/latex
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
