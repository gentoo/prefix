# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/bison/bison-2.3.ebuild,v 1.10 2007/12/27 19:29:06 vapier Exp $

inherit toolchain-funcs flag-o-matic

DESCRIPTION="A yacc-compatible parser generator"
HOMEPAGE="http://www.gnu.org/software/bison/bison.html"
SRC_URI="mirror://gnu/bison/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls static"

DEPEND="nls? ( sys-devel/gettext )"

RDEPEND="sys-devel/m4"

src_compile() {
	use static && append-ldflags -static
	econf $(use_enable nls) || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die

	# This one is installed by dev-util/yacc
	mv "${ED}"/usr/bin/yacc{,.bison} || die

	# We do not need this.
	rm -r "${ED}"/usr/lib* || die

	dodoc AUTHORS NEWS ChangeLog README OChangeLog THANKS TODO
}

pkg_postinst() {
	if [[ ! -e ${EROOT}/usr/bin/yacc ]] ; then
		ln -s yacc.bison "${EROOT}"/usr/bin/yacc
	fi
}
