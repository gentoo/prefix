# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/mercurial/mercurial-0.9.5.ebuild,v 1.1 2007/11/07 10:57:51 aross Exp $

EAPI="prefix"

inherit bash-completion distutils elisp-common flag-o-matic

DESCRIPTION="Scalable distributed SCM"
HOMEPAGE="http://www.selenic.com/mercurial/"
SRC_URI="http://www.selenic.com/mercurial/release/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE="bugzilla cvs darcs emacs git gpg subversion test zsh-completion"

CDEPEND=">=dev-lang/python-2.3"
RDEPEND="${CDEPEND}
	bugzilla? ( dev-python/mysql-python )
	cvs? ( dev-util/cvs )
	darcs? ( || ( dev-python/celementtree dev-python/elementtree ) )
	git? ( dev-util/git )
	gpg? ( app-crypt/gnupg )
	subversion? ( dev-util/subversion )
	zsh-completion? ( app-shells/zsh )"
DEPEND="${CDEPEND}
	emacs? ( virtual/emacs )
	test? ( app-arch/unzip )"

PYTHON_MODNAME="${PN} hgext"
SITEFILE="70${PN}-gentoo.el"

src_compile() {
	filter-flags -ftracer -ftree-vectorize

	distutils_src_compile

	if use emacs; then
		cd "${S}"/contrib
		elisp-compile mercurial.el || die "elisp-compile failed!"
	fi

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
		elisp-install ${PN} contrib/mercurial.el* || die "elisp-install failed!"
		elisp-site-file-install "${FILESDIR}"/${SITEFILE}
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
