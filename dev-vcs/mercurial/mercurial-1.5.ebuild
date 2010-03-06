# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-vcs/mercurial/mercurial-1.5.ebuild,v 1.1 2010/03/06 13:26:58 djc Exp $

EAPI=2

inherit bash-completion elisp-common flag-o-matic eutils distutils

DESCRIPTION="Scalable distributed SCM"
HOMEPAGE="http://mercurial.selenic.com/"
SRC_URI="http://mercurial.selenic.com/release/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="bugzilla emacs gpg test tk zsh-completion"

CDEPEND=">=dev-lang/python-2.4[threads]"
RDEPEND="${CDEPEND}
	bugzilla? ( dev-python/mysql-python )
	gpg? ( app-crypt/gnupg )
	tk? ( dev-lang/tk )
	zsh-completion? ( app-shells/zsh )"
DEPEND="${CDEPEND}
	emacs? ( virtual/emacs )
	test? ( app-arch/unzip
		dev-python/pygments )"

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

	rm -f doc/*.?.txt
	dodoc CONTRIBUTORS PKG-INFO README doc/*.txt
	cp hgweb*.cgi "${ED}"/usr/share/doc/${PF}/

	dobin hgeditor
	dobin contrib/hgk
	dobin contrib/hg-ssh

	rm -f contrib/hgk contrib/hg-ssh

	rm -f contrib/bash_completion
	cp -r contrib "${ED}"/usr/share/doc/${PF}/
	doman doc/*.?

	cat > "${T}/80mercurial" <<-EOF
HG="${EPREFIX}/usr/bin/hg"
EOF
	doenvd "${T}/80mercurial"

	if use emacs; then
		elisp-install ${PN} contrib/mercurial.el* || die "elisp-install failed!"
		elisp-site-file-install "${FILESDIR}"/${SITEFILE}
	fi
}

src_test() {
	cd "${S}/tests/"
	rm -rf *svn*				# Subversion tests fail with 1.5
	rm -f test-archive			# Fails due to verbose tar output changes
	rm -f test-convert-baz*		# GNU Arch baz
	rm -f test-convert-cvs*		# CVS
	rm -f test-convert-darcs*	# Darcs
	rm -f test-convert-git*		# git
	rm -f test-convert-mtn*		# monotone
	rm -f test-convert-tla*		# GNU Arch tla
	rm -f test-doctest*			# doctest always fails with python 2.5.x
	if [[ ${EUID} -eq 0 ]]; then
		einfo "Removing tests which require user privileges to succeed"
		rm -f test-command-template	# Test is broken when run as root
		rm -f test-convert			# Test is broken when run as root
		rm -f test-lock-badness		# Test is broken when run as root
		rm -f test-permissions		# Test is broken when run as root
		rm -f test-pull-permission	# Test is broken when run as root
	fi
	local testdir="${T}/tests"
	rm -rf "${testdir}"
	einfo "Running Mercurial tests ..."
	python run-tests.py --tmpdir="${testdir}" || die "test failed"
}

pkg_postinst() {
	distutils_pkg_postinst
	use emacs && elisp-site-regen
	bash-completion_pkg_postinst

	elog "If you want to convert repositories from other tools using convert"
	elog "extension please install correct tool:"
	elog "  dev-util/cvs"
	elog "  dev-util/darcs"
	elog "  dev-util/git"
	elog "  dev-vcs/monotone"
	elog "  dev-util/subversion"
}

pkg_postrm() {
	distutils_pkg_postrm
	use emacs && elisp-site-regen
}
