# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-dns/bind-tools/bind-tools-9.3.2-r3.ebuild,v 1.2 2006/07/20 20:25:48 flameeyes Exp $

EAPI="prefix"

inherit flag-o-matic

MY_P=${P//-tools}
MY_P=${MY_P/_}
S=${WORKDIR}/${MY_P}
DESCRIPTION="bind tools: dig, nslookup, and host"
HOMEPAGE="http://www.isc.org/products/BIND/bind9.html"
SRC_URI="ftp://ftp.isc.org/isc/bind9/${PV/_}/${MY_P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE="idn ipv6"

DEPEND=""

src_unpack() {
	unpack ${A} || die
	cd ${S} || die

	use idn && {
		epatch ${S}/contrib/idn/idnkit-1.0-src/patch/bind9/bind-${PV}-patch

		cd ${S}/contrib/idn/idnkit-1.0-src
		epatch ${FILESDIR}/${PN}-configure.patch
	}
}

src_compile() {
	use ipv6 && myconf="${myconf} --enable-ipv6" || myconf="${myconf} --enable-ipv6=no"

	econf ${myconf} || die "Configure failed"

	cd ${S}/lib
	emake -j1 || die "make failed in /lib"

	cd ${S}/bin/dig
	emake -j1 || die "make failed in /bin/dig"

	cd ${S}/lib/lwres/
	emake -j1 || die "make failed in /lib/lwres"

	cd ${S}/bin/nsupdate/
	emake -j1 || die "make failed in /bin/nsupdate"

	use idn && {
		cd ${S}/contrib/idn/idnkit-1.0-src
		econf || die "idn econf failed"
		emake -j1 || die "idn emake failed"
	}
}

src_install() {
	dodoc README CHANGES FAQ

	cd ${S}/bin/dig
	dobin dig host nslookup || die
	doman dig.1 host.1 nslookup.1 || die

	cd ${S}/bin/nsupdate
	dobin nsupdate || die
	doman nsupdate.8 || die
	dohtml nsupdate.html || die
}
