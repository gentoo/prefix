# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/bison/bison-2.2.ebuild,v 1.12 2006/10/26 03:17:11 vapier Exp $

EAPI="prefix"

inherit toolchain-funcs flag-o-matic eutils gnuconfig

DESCRIPTION="A yacc-compatible parser generator"
HOMEPAGE="http://www.gnu.org/software/bison/bison.html"
SRC_URI="mirror://gnu/bison/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="nls static"

DEPEND="nls? ( sys-devel/gettext )"

RDEPEND="sys-devel/m4"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.32-extfix.patch
}

src_compile() {
	# Bug 29017 says that bison has compile-time issues with
	# -march=k6* prior to 3.4CVS.  Use -march=i586 instead
	# (04 Feb 2004 agriffis)
	if (( $(gcc-major-version) == 3 && $(gcc-minor-version) < 4 )) ; then
		replace-cpu-flags k6 k6-1 k6-2 i586
	fi

	use static && append-ldflags -static
	econf $(use_enable nls) || die
	emake || die
}

src_install() {
	make DESTDIR="${D}" install || die

	# This one is installed by dev-util/yacc
	mv "${ED}"/usr/bin/yacc{,.bison} || die

	# We do not need this.
	rm -r "${ED}"/usr/lib

	dodoc AUTHORS NEWS ChangeLog README REFERENCES OChangeLog doc/FAQ
}

pkg_postinst() {
	if [[ ! -e ${EROOT}/usr/bin/yacc ]] ; then
		ln -s yacc.bison "${EROOT}"/usr/bin/yacc
	fi
}
