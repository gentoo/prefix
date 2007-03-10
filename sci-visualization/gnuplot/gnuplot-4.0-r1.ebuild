# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-visualization/gnuplot/gnuplot-4.0-r1.ebuild,v 1.3 2006/10/10 21:48:15 g2boojum Exp $

EAPI="prefix"

inherit flag-o-matic eutils elisp-common

MY_P="${P}.0"

DESCRIPTION="Command-line driven interactive plotting program"
HOMEPAGE="http://www.gnuplot.info/"
SRC_URI="mirror://sourceforge/gnuplot/${MY_P}.tar.gz"

LICENSE="gnuplot"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE="doc emacs gd ggi pdf plotutils png readline svga X xemacs"

DEPEND="
	xemacs? ( virtual/xemacs )
	emacs? ( virtual/emacs !app-emacs/gnuplot-mode )
	pdf? ( media-libs/pdflib )
	ggi? ( media-libs/libggi )
	png? ( media-libs/libpng )
	gd? ( >=media-libs/gd-2 )
	doc? ( virtual/tetex )
	X? ( || ( x11-libs/libXaw virtual/x11 ) )
	svga? ( media-libs/svgalib )
	readline? ( >=sys-libs/readline-4.2 )
	plotutils? ( media-libs/plotutils )"

S=${WORKDIR}/${MY_P}

E_SITEFILE="50gnuplot-gentoo.el"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/header-order.patch
	epatch ${FILESDIR}/pdflib-6-compat.patch
}

src_compile() {
	# heiko_> gnuplot doesn't compile if several -m's are set (compiler crash)
	use ppc-macos && filter-flags -m* -fast

	local myconf="--with-gihdir=${EPREFIX}/usr/share/${PN}/gih"

	myconf="${myconf} $(use_with X x)"
	myconf="${myconf} $(use_with svga linux-vga)"
	myconf="${myconf} $(use_with gd)"
	myconf="${myconf} $(use_with plotutils plot "${EPREFIX}"/usr/lib)"
	myconf="${myconf} $(use_with png png "${EPREFIX}"/usr/lib)"
	myconf="${myconf} $(use_with pdf pdf "${EPREFIX}"/usr/lib)"

	use ggi \
		&& myconf="${myconf} --with-ggi=${EPREFIX}/usr/lib --with-xmi=${EPREFIX}/usr/lib" \
		|| myconf="${myconf} --without-ggi"

	use readline \
		&& myconf="${myconf} --with-readline=gnu --enable-history-file" \
		|| myconf="${myconf} --with-readline"

	myconf="${myconf} --without-lisp-files"

	# This is a hack to avoid sandbox violations when using the Linux console.
	# Creating the DVI and PDF tutorials require /dev/svga to build the
	# example plots.
	addwrite /dev/svga:/dev/mouse:/dev/tts/0

	econf ${myconf} || die
	emake || die

	if use doc ; then
		cd docs
		make pdf || die
		cd ../tutorial
		make pdf || die
	fi
}

src_install () {
	make DESTDIR=${D} install || die

	if use emacs; then
		cd lisp
		einfo "Configuring gnuplot-mode for emacs..."
		EMACS="emacs" lispdir="${EPREFIX}/usr/share/emacs/site-lisp/${PN}" econf || die
		make DESTDIR=${D} install || die
		make clean
		cd ..

		# Gentoo emacs site-lisp configuration
		string="(add-to-list 'load-path \"${EPREFIX}/usr/share/emacs/site-lisp/${PN}\")"
		echo -e ";;; Gnuplot site-lisp configuration\n\n${string}\n" > ${E_SITEFILE}
		sed '/^;; move/,+4 d' lisp/dotemacs >> ${E_SITEFILE}
		elisp-site-file-install ${E_SITEFILE}
	fi

	if use xemacs; then
		cd lisp
		einfo "Configuring gnuplot-mode for xemacs..."
		EMACS="xemacs" lispdir="${EPREFIX}/usr/lib/xemacs/site-packages/${PN}" econf || die
		make DESTDIR=${D} install || {
			ewarn "Compiling/installing gnuplot-mode for xemacs has failed."
			ewarn "I need xemacs-base to be installed before I can compile"
			ewarn "the gnuplot-mode lisp files for xemacs successfully."
			ewarn "Please try re-emerging me after app-xemacs/xemacs-base"
			ewarn "has been successfuly emerged."
			die
			}
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
}

pkg_postinst() {
	use emacs && elisp-site-regen
	if use svga ; then
		einfo "In order to enable ordinary users to use SVGA console graphics"
		einfo "gnuplot needs to be set up as setuid root.  Please note that"
		einfo "this is usually considered to be a security hazard."
		einfo "As root, manually \"chmod u+s /usr/bin/gnuplot\"."
	fi
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
