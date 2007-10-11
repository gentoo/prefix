# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-tcltk/tcllib/tcllib-1.9.ebuild,v 1.2 2007/09/15 07:50:13 uberlord Exp $

EAPI="prefix"

DESCRIPTION="Tcl Standard Library."
HOMEPAGE="http://www.tcl.tk/software/tcllib/"
SRC_URI="mirror://sourceforge/tcllib/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
IUSE="examples"
KEYWORDS="~amd64 ~ia64 ~mips ~x86 ~x86-fbsd ~x86-macos"

DEPEND=">=dev-lang/tcl-8.3.1"

src_install() {
	emake DESTDIR="${D}" install || die

	dodoc ChangeLog DESCRIPTION.txt README* STATUS devdoc/*.txt
	dohtml devdoc/*.html
	if use examples ; then
		for f in $(find examples -type f); do
			docinto $(dirname $f)
			dodoc $f
		done
	fi
}
