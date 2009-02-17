# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/rst/rst-0.4-r1.ebuild,v 1.8 2008/09/20 17:55:52 vapier Exp $

EAPI="prefix"

inherit elisp eutils

DESCRIPTION="ReStructuredText support for Emacs"
HOMEPAGE="http://www.emacswiki.org/cgi-bin/wiki/reStructuredText"
SRC_URI="mirror://sourceforge/docutils/docutils-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
IUSE=""

S="${WORKDIR}/docutils-${PV}/tools/editors/emacs"
SITEFILE=51${PN}-gentoo.el
DOCS="README.txt"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-lazy-lock-mode-fix.patch"
}
