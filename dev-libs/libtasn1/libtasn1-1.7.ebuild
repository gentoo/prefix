# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libtasn1/libtasn1-1.7.ebuild,v 1.1 2008/12/26 22:55:51 dragonheart Exp $

DESCRIPTION="provides ASN.1 structures parsing capabilities for use with GNUTLS"
HOMEPAGE="http://www.gnutls.org/"
SRC_URI="mirror://gnu/gnutls/${P}.tar.gz"

LICENSE="GPL-3 LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc"

DEPEND=">=dev-lang/perl-5.6
	sys-devel/bison"
RDEPEND=""

src_install() {
	emake DESTDIR="${D}" install || die "installed failed"
	dodoc AUTHORS ChangeLog NEWS README THANKS
	use doc && dodoc doc/asn1.ps
}
