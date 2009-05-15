# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/cook/cook-1.0.2-r1.ebuild,v 1.9 2009/05/13 17:22:49 mr_bones_ Exp $

inherit toolchain-funcs

DESCRIPTION="COOK is an embedded language which can be used as a macro preprocessor and for similar text processing."
HOMEPAGE="http://cook.sourceforge.net/"
SRC_URI="mirror://sourceforge/cook/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-linux ~ppc-macos ~sparc-solaris"
IUSE=""
DEPEND="virtual/libc"

src_compile() {
	cd ${S}
	emake CC="$(tc-getCC)" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" || die "emake failed"
}

src_install() {
	cd ${S}
	dodoc README doc/cook.txt doc/cook.html || die "dodoc failed"
	dodir /usr/share/doc/${PF}/example || die "dodir failed"
	cd ${S}/test
	insinto /usr/share/doc/${PF}/example
	doins pcb.dbdef pcb.dg pcbprol.ps tempsens.pcb || die "doins failed"
	cd ${S}
	newbin src/cook cookproc || die "newbin failed"

	(
		echo "NOTICE:"
		echo
		echo " /usr/bin/cook has been renamed to /usr/bin/cookproc in Gentoo"
		echo
		echo " -- Karl Trygve Kalleberg <karltk@gentoo.org>"
	) > ${ED}/usr/share/doc/${PF}/README.Gentoo
}

pkg_postinst() {
	ewarn "/usr/bin/cook has been renamed to /usr/bin/cookproc"
}
