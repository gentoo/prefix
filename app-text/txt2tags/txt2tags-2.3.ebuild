# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/txt2tags/txt2tags-2.3.ebuild,v 1.2 2006/11/28 20:20:38 opfer Exp $

EAPI="prefix"

inherit elisp-common

IUSE="emacs tk"

DESCRIPTION="Txt2tags is a tool for generating marked up documents (HTML, SGML, ...) from a plain text file with markup."
SRC_URI="http://txt2tags.sourceforge.net/src/${P}.tgz"
HOMEPAGE="http://txt2tags.sourceforge.net/"

LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
DEPEND="virtual/python
	tk? ( dev-lang/tk )
	emacs? ( virtual/emacs )"

pkg_setup() {

	# need to test if the tk support in python is working
	if use tk; then
		if ! python -c "import _tkinter" 2>&1 > /dev/null ; then
			echo
			eerror "You have requested tk, but your build of Python"
			eerror "doesnt support import _tkinter. You may need to"
			eerror "remerge dev-lang/python, or build ${P}"
			eerror "with USE=\"-tk\""
			die
		fi
	fi
}

src_compile() {
	if use emacs; then
		elisp-comp extras/txt2tags-mode.el
	fi
}

SITEFILE="50${PN}-gentoo.el"

src_install() {
	dobin txt2tags

	dodoc README* TEAM TODO ChangeLog* doc/txt2tagsrc
	dohtml -r doc/*
	insinto /usr/share/doc/${PF}
	doins doc/userguide.pdf
	# samples go into "samples" doc directory
	docinto samples
	dodoc samples/sample.*
	docinto samples/css
	dodoc samples/css/*
	docinto samples/img
	dodoc samples/img/*
	# extras go into "extras" doc directory
	docinto extras
	dodoc extras/*

	newman doc/manpage.man txt2tags.1

	# emacs support
	if use emacs; then
		elisp-install ${PN} extras/txt2tags-mode.el
		elisp-site-file-install ${FILESDIR}/${SITEFILE}
	fi
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
