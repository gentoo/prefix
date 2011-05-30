# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/bison/bison-2.5.ebuild,v 1.1 2011/05/16 19:37:21 vapier Exp $

EAPI="2"

inherit eutils

DESCRIPTION="A yacc-compatible parser generator"
HOMEPAGE="http://www.gnu.org/software/bison/bison.html"
SRC_URI="mirror://gnu/bison/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls static"

DEPEND="nls? ( sys-devel/gettext )"
RDEPEND="sys-devel/m4"

src_configure() {
	use static && append-ldflags -static
	econf $(use_enable nls)
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
