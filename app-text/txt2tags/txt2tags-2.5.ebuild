# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/txt2tags/txt2tags-2.5.ebuild,v 1.3 2009/08/15 21:58:22 betelgeuse Exp $

EAPI="2"
PYTHON_USE_WITH="tk"
PYTHON_USE_WITH_OPT="tk"

inherit eutils elisp-common python

DESCRIPTION="A tool for generating marked up documents (HTML, SGML, ...) from a plain text file with markup"
HOMEPAGE="http://txt2tags.sourceforge.net/"
SRC_URI="mirror://sourceforge/txt2tags/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris"
IUSE="emacs tk"

DEPEND="virtual/python
	tk? ( dev-lang/tk )
	emacs? ( virtual/emacs )"

SITEFILE="51${PN}-gentoo.el"

src_compile() {
	if use emacs; then
		elisp-compile extras/txt2tags-mode.el || die "elisp-compile failed"
	fi
}

src_install() {
	dobin txt2tags

	dodoc README TODO ChangeLog*
	insinto /usr/share/doc/${PF}
	doins doc/*.{pdf,t2t}
	# samples go into "samples" doc directory
	docinto samples
	dodoc samples/sample.*
	docinto samples/css
	dodoc samples/css/*
	docinto samples/img
	dodoc samples/img/*
	docinto samples/module
	dodoc samples/module/*
	# extras go into "extras" doc directory
	docinto extras
	dodoc extras/*
	newman doc/manpage.man txt2tags.1

	# make .po files
	for pofile in "${S}"/po/*.po; do
		msgfmt -o ${pofile%%.po}.mo ${pofile}
	done
	domo po/*.mo

	# emacs support
	if use emacs; then
		elisp-install ${PN} extras/txt2tags-mode.{el,elc}
		elisp-site-file-install "${FILESDIR}/${SITEFILE}"
	fi
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
