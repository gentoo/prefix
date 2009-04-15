# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/mhash/mhash-0.9.9.9.ebuild,v 1.1 2009/04/12 21:46:02 robbat2 Exp $

inherit eutils autotools

DESCRIPTION="library providing a uniform interface to a large number of hash algorithms"
HOMEPAGE="http://mhash.sourceforge.net/"
SRC_URI="mirror://sourceforge/mhash/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix for issues in bug #181563
	#epatch "${FILESDIR}/${PN}-0.9.9-mutils-align.patch"

	epatch "${FILESDIR}"/${PN}-0.9.9-fix-mem-leak.patch
	epatch "${FILESDIR}"/${PN}-0.9.9-fix-snefru-segfault.patch
	epatch "${FILESDIR}"/${PN}-0.9.9-fix-whirlpool-segfault.patch
	epatch "${FILESDIR}"/${PN}-0.9.9-autotools-namespace-stomping.patch

#	eautoreconf # need new libtool for interix
}

src_compile() {
	econf \
		--enable-static \
		--enable-shared || die
	emake || die "make failure"
	cd doc && emake mhash.html || die "failed to build html"
}

src_install() {
	dodir /usr/{bin,include,lib}
	make install DESTDIR="${D}" || die "install failure"

	dodoc AUTHORS INSTALL NEWS README TODO THANKS ChangeLog
	dodoc doc/skid* doc/*.c
	dohtml doc/mhash.html || die "dohtml failed"
}
