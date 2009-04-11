# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/bison/bison-2.4-r1.ebuild,v 1.3 2008/11/14 08:50:29 vapier Exp $

inherit toolchain-funcs flag-o-matic

DESCRIPTION="A yacc-compatible parser generator"
HOMEPAGE="http://www.gnu.org/software/bison/bison.html"
SRC_URI="mirror://gnu/bison/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls static"

# need flex since we patch scan-code.l in ${P}-compat.patch
DEPEND="nls? ( sys-devel/gettext )
	sys-devel/flex"
RDEPEND="sys-devel/m4"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-compat.patch
	# since we patch sources, update mtimes on docs so we dont regen
	touch doc/bison.1 doc/bison.info doc/cross-options.texi
}

src_compile() {
	use static && append-ldflags -static
	econf $(use_enable nls) || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die

	# This one is installed by dev-util/yacc
	mv "${ED}"/usr/bin/yacc{,.bison} || die
	mv "${ED}"/usr/share/man/man1/yacc{,.bison}.1 || die

	# We do not need this.
	rm -r "${ED}"/usr/lib* || die

	dodoc AUTHORS NEWS ChangeLog README OChangeLog THANKS TODO
}

pkg_postinst() {
	if [[ ! -e ${EROOT}/usr/bin/yacc ]] ; then
		ln -s yacc.bison "${EROOT}"/usr/bin/yacc
	fi
}
