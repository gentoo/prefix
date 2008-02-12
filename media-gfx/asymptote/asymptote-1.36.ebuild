# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/asymptote/asymptote-1.36.ebuild,v 1.1 2007/10/27 20:15:58 centic Exp $

EAPI="prefix"

inherit eutils elisp-common latex-package

DESCRIPTION="A vector graphics language that provides a framework for technical drawing"
HOMEPAGE="http://asymptote.sourceforge.net/"
SRC_URI="mirror://sourceforge/asymptote/${P}.src.tgz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"

IUSE="boehm-gc doc fftw emacs gsl vim-syntax"

RDEPEND=">=sys-libs/readline-4.3-r5
	>=sys-libs/ncurses-5.4-r5
	dev-libs/libsigsegv
	boehm-gc? ( >=dev-libs/boehm-gc-7.0 )
	virtual/tetex
	fftw? ( >=sci-libs/fftw-3.0.1 )
	emacs? ( virtual/emacs )
	gsl? ( sci-libs/gsl )
	vim-syntax? ( || ( app-editors/vim app-editors/gvim ) )"
DEPEND="${RDEPEND}
	>=sys-devel/autoconf-2.5
	>=sys-devel/bison-1.875
	>=sys-devel/flex-2.5.4a-r5
	doc? ( >=media-gfx/imagemagick-6.1.3.2
		virtual/ghostscript
		>=sys-apps/texinfo-4.7-r1 )"

SITEFILE=64${PN}-gentoo.el

pkg_setup() {
	# checking if Boehm garbage collector was compiled with c++ support
	if use boehm-gc ; then
		if ! built_with_use dev-libs/boehm-gc nocxx ; then
			einfo "dev-libs/boehm-gc has been compiled with nocxx use flag disabled"
		else
			echo
			eerror "You have to rebuild dev-libs/boehm-gc enabling c++ support"
			die
		fi
	fi

	if ! built_with_use dev-lang/python tk; then
		eerror "Please reemerge dev-lang/python with 'tk' support or xasy will"
		eerror "not work. In order to fix this, execute the following:"
		eerror "echo \"dev-lang/python tk\" >> /etc/portage/package.use"
		eerror "and reemerge dev-lang/python before emerging asymptote."
		die "requires dev-lang/python with use-flag 'tk'!!"
	fi
}

src_unpack() {
	unpack ${A}

	cd "${S}"

	# Fixing fftw and gsl enabling
	epatch "${FILESDIR}/${P}-configure-ac.patch"
	einfo "Patching configure.ac"
	sed -i \
		-e "s:Datadir/doc/asymptote:Datadir/doc/${PF}:" \
		configure.ac || die "sed configure.ac failed"

	einfo "Building configure"
	WANT_AUTOCONF=2.5 autoconf

	epatch "${FILESDIR}/${P}-makefile.patch"
}

src_compile() {
	for dir in `find "${EPREFIX}"/var/cache/fonts -type d`; do addwrite ${dir}; done

	# for the CPPFLAGS see http://sourceforge.net/forum/forum.php?thread_id=1683277&forum_id=409349
	myconf="--with-latex=${EPREFIX}/usr/share/texmf/tex/latex --disable-gc-debug CPPFLAGS=-DHAVE_SYS_TYPES_H"
	if use boehm-gc; then
		myconf="${myconf} --enable-gc=system"
	else
		myconf="${myconf} --disable-gc"
	fi

	econf ${myconf} $(use_with fftw) $(use_with gsl) || die "econf failed"
	emake || die "emake failed"

	if use emacs ; then
		elisp-compile base/*.el || die "elisp-compile failed"
	fi
}

src_install() {
	for dir in `find "${EPREFIX}"/var/cache/fonts -type d`; do addwrite ${dir}; done

	if use doc; then
		target="install-all"
	else
		target="install"
	fi

	emake DESTDIR="${D}" ${target} || die "emake install failed"

	dodoc BUGS ChangeLog README ReleaseNotes TODO

	if use emacs ; then
		elisp-install ${PN} base/*.el base/*.elc
		elisp-site-file-install "${FILESDIR}/${SITEFILE}"
	fi

	if use vim-syntax ; then
		insinto /usr/share/vim/vimfiles/syntax
		doins base/asy.vim
		insinto /usr/share/vim/vimfiles/ftdetect
		doins "${FILESDIR}/asy-ftd.vim"
	fi
}

pkg_postinst() {
	latex-package_rehash

	elog 'Use the variable ASYMPTOTE_PSVIEWER to set the postscript viewer'
	elog 'Use the variable ASYMPTOTE_PDFVIEWER to set the PDF viewer'

	use emacs && elisp-site-regen
}

pkg_postrm() {
	latex-package_rehash
	use emacs && elisp-site-regen
}
