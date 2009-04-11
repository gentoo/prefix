# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/po-mode/po-mode-0.17.ebuild,v 1.8 2008/01/13 00:27:44 vapier Exp $

inherit elisp

DESCRIPTION="Major mode for GNU gettext PO files"
HOMEPAGE="http://www.gnu.org/software/gettext/"
SRC_URI="mirror://gnu/gettext/gettext-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

S="${WORKDIR}/gettext-${PV}/gettext-tools/misc"
SITEFILE=51${PN}-gentoo.el

src_compile() {
	elisp-compile po-mode.el po-compat.el || die "elisp-compile failed"
}
