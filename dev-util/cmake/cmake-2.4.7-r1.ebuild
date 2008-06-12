# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cmake/cmake-2.4.7-r1.ebuild,v 1.4 2008/02/22 18:00:15 ingmar Exp $

EAPI="prefix"

inherit elisp-common toolchain-funcs eutils versionator qt3 flag-o-matic

DESCRIPTION="Cross platform Make"
HOMEPAGE="http://www.cmake.org/"
SRC_URI="http://www.cmake.org/files/v$(get_version_component_range 1-2)/${P}.tar.gz"

LICENSE="CMake"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="emacs vim-syntax"

DEPEND="emacs? ( virtual/emacs )
	vim-syntax? ( || (
		app-editors/vim
		app-editors/gvim ) )"
RDEPEND="${DEPEND}"

SITEFILE="50${PN}-gentoo.el"
VIMFILE="${PN}.vim"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Upstream patch to make sure KDE4 is found. cf. bug 191412.
	epatch "${FILESDIR}/${P}-findkde4.patch"
}

src_compile() {
	if [ "$(gcc-major-version)" -eq "3" ] ; then
		append-flags "-fno-stack-protector"
	fi

	tc-export CC CXX LD
	./bootstrap \
		--prefix="${EPREFIX}"/usr \
		--docdir=/share/doc/${PN} \
		--datadir=/share/${PN} \
		--mandir=/share/man || die "./bootstrap failed"
	emake || die
	if use emacs; then
		elisp-compile Docs/cmake-mode.el || die "elisp compile failed"
	fi
}

src_test() {
	einfo "Self tests broken"
	make test || \
		einfo "note test failure on qtwrapping was expected - nature of portage rather than a true failure"
}

src_install() {
	make install DESTDIR="${D}" || die "install failed"
	mv "${ED}"usr/share/doc/cmake "${ED}"usr/share/doc/${PF}
	if use emacs; then
		elisp-install ${PN} Docs/cmake-mode.el Docs/cmake-mode.elc || die "elisp-install failed"
		elisp-site-file-install "${FILESDIR}/${SITEFILE}"
	fi
	if use vim-syntax; then
		insinto /usr/share/vim/vimfiles/syntax
		doins "${S}"/Docs/cmake-syntax.vim

		insinto /usr/share/vim/vimfiles/indent
		doins "${S}"/Docs/cmake-indent.vim

		insinto /usr/share/vim/vimfiles/ftdetect
		doins "${FILESDIR}/${VIMFILE}"
	fi
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
