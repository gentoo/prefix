# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/rst/rst-0.5.ebuild,v 1.6 2009/08/31 18:08:56 ranger Exp $

inherit elisp

DESCRIPTION="ReStructuredText support for Emacs"
HOMEPAGE="http://www.emacswiki.org/cgi-bin/wiki/reStructuredText"
SRC_URI="mirror://sourceforge/docutils/docutils-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
IUSE=""

S="${WORKDIR}/docutils-${PV}/tools/editors/emacs"
DOCS="README.txt"
SITEFILE="51${PN}-gentoo.el"
