# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libtasn1/libtasn1-2.9-r1.ebuild,v 1.7 2011/01/15 15:24:59 maekke Exp $

EAPI="3"

DESCRIPTION="ASN.1 library"
HOMEPAGE="http://www.gnu.org/software/libtasn1/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-3 LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc"

DEPEND=">=dev-lang/perl-5.6
	sys-devel/bison"
RDEPEND=""

src_compile() {
	econf || die
	emake || die
}

src_configure(){
	local myconf
	[[ "${VALGRIND_TESTS}" == "0" ]] && myconf+=" --disable-valgrind-tests"
	econf ${myconf}
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README THANKS || die "dodoc failed"

	if use doc; then
		dodoc doc/libtasn1.ps || die "dodoc failed"
	fi
}
