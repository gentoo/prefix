# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-tcltk/tcllib/tcllib-1.10.ebuild,v 1.1 2007/12/24 04:02:22 matsuu Exp $

EAPI="prefix"

DESCRIPTION="Tcl Standard Library."
HOMEPAGE="http://www.tcl.tk/software/tcllib/"
SRC_URI="mirror://sourceforge/tcllib/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
IUSE="examples"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"

DEPEND=">=dev-lang/tcl-8.4"

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
