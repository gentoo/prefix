# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cmake/cmake-2.4.8.ebuild,v 1.2 2008/02/11 19:41:38 flameeyes Exp $

EAPI="prefix"

inherit elisp-common toolchain-funcs eutils versionator qt3 flag-o-matic

MY_PV="${PV/rc/RC-}"
MY_P="${PN}-$(replace_version_separator 3 - ${MY_PV})"

DESCRIPTION="Cross platform Make"
HOMEPAGE="http://www.cmake.org/"
SRC_URI="http://www.cmake.org/files/v$(get_version_component_range 1-2)/${MY_P}.tar.gz"

LICENSE="CMake"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="emacs vim-syntax"

DEPEND=">=net-misc/curl-7.16.4
	>=dev-libs/expat-2.0.1
	>=dev-libs/libxml2-2.6.28
	>=dev-libs/xmlrpc-c-1.06.09
	emacs? ( virtual/emacs )
	vim-syntax? ( || (
		app-editors/vim
		app-editors/gvim ) )"
RDEPEND="${DEPEND}"

SITEFILE="50${PN}-gentoo.el"
VIMFILE="${PN}.vim"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	if ! built_with_use -o dev-libs/xmlrpc-c curl libwww; then
		echo
		eerror "${PN} requires dev-libs/xmlrpc-c to be built with either the 'libwww' or"
		eerror "the 'curl' USE flag or both enabled."
		eerror "Please re-emerge dev-libs/xmlrpc-c with USE=\"libwww\" or USE=\"curl\"."
		echo
		die "Please re-emerge dev-libs/xmlrpc-c with USE=\"libwww\" or USE=\"curl\"."
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Upstream's version is broken. Reported in upstream bugs 3498, 3637, 4145.
	# Fixed version kindly provided on 4145 by Axel Roebel.
	cp "${FILESDIR}/FindSWIG.cmake" "${S}/Modules/"
}

src_compile() {
	if [[ "$(gcc-major-version)" -eq "3" ]] ; then
		append-flags "-fno-stack-protector"
	fi

	tc-export CC CXX LD

	./bootstrap \
		--system-libs \
		--prefix="${EPREFIX}"/usr \
		--docdir=/share/doc/${PN} \
		--datadir=/share/${PN} \
		--mandir=/share/man || die "./bootstrap failed"
	emake || die "emake failed."
	if use emacs; then
		elisp-compile Docs/cmake-mode.el || die "elisp compile failed"
	fi
}

src_test() {
	emake test || \
		einfo "note test failure on qtwrapping was expected - nature of portage rather than a true failure"
}

src_install() {
	emake install DESTDIR="${D}" || die "install failed"
	mv "${ED}usr/share/doc/cmake" "${ED}usr/share/doc/${PF}"
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
