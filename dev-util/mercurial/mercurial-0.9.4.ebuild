# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/mercurial/mercurial-0.9.4.ebuild,v 1.1 2007/07/04 08:34:39 aross Exp $

EAPI="prefix"

inherit bash-completion distutils elisp-common flag-o-matic

DESCRIPTION="Scalable distributed SCM"
HOMEPAGE="http://www.selenic.com/mercurial/"
SRC_URI="http://www.selenic.com/mercurial/release/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE="emacs test zsh-completion"

RDEPEND=">=dev-lang/python-2.3
	zsh-completion? ( app-shells/zsh )"
DEPEND="${RDEPEND}
	emacs? ( virtual/emacs )
	test? ( app-arch/unzip )"

PYTHON_MODNAME="${PN} hgext"

src_compile() {
	filter-flags -ftracer -ftree-vectorize

	distutils_src_compile

	if use emacs; then
		cd "${S}"/contrib
		elisp-compile mercurial.el || die "Emacs modules failed!"
	fi

	rm -rf contrib/vim	# app-vim/hgcommand app-vim/hgmenu
	rm -rf contrib/{win32,macosx}
}

src_install() {
	distutils_src_install

	dobashcompletion contrib/bash_completion ${PN}

	if use zsh-completion ; then
		insinto /usr/share/zsh/site-functions
		newins contrib/zsh_completion _hg
	fi

	dodoc CONTRIBUTORS PKG-INFO README *.txt
	cp hgweb*.cgi "${ED}"/usr/share/doc/${PF}/
	rm -f contrib/bash_completion
	cp -r contrib "${ED}"/usr/share/doc/${PF}/
	doman doc/*.?

	if use emacs; then
		insinto ${SITELISP}/${PN}
		doins contrib/mercurial.el*
		elisp-site-file-install "${FILESDIR}"/70mercurial-gentoo.el
	fi
}

pkg_postinst() {
	distutils_pkg_postinst
	use emacs && elisp-site-regen
	bash-completion_pkg_postinst
}

pkg_postrm() {
	distutils_pkg_postrm
	use emacs && elisp-site-regen
}
