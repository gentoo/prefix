# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-dns/bind-tools/bind-tools-9.4.1.ebuild,v 1.1 2007/05/01 13:19:20 voxus Exp $

EAPI="prefix"

inherit flag-o-matic

MY_P=${P//-tools}
S=${WORKDIR}/${MY_P}
DESCRIPTION="bind tools: dig, nslookup, and host"
HOMEPAGE="http://www.isc.org/products/BIND/bind9.html"
SRC_URI="ftp://ftp.isc.org/isc/bind9/${PV}/${MY_P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-solaris"
IUSE="idn ipv6"

DEPEND="idn? ( || ( sys-libs/glibc dev-libs/libiconv ) )"

src_unpack() {
	unpack "${A}" || die
	cd "${S}" || die

	use idn && {
		# BIND 9.4.0 doesn't have this patch
		# epatch ${S}/contrib/idn/idnkit-1.0-src/patch/bind9/bind-${PV}-patch

		cd ${S}/contrib/idn/idnkit-1.0-src
		epatch ${FILESDIR}/${PN}-configure.patch
		cd -
	}

	# bug #151839
	sed \
		-e 's:CDEFINES =:CDEFINES = -USO_BSDCOMPAT:' \
		-i lib/isc/unix/Makefile.in
}

src_compile() {
	local myconf=
	use ipv6 && myconf="${myconf} --enable-ipv6" || myconf="${myconf} --enable-ipv6=no"
	
	# bind hardcoded refers to /usr/lib when looking for openssl, since the
	# ebuild doesn't depend on ssl, disable it
	myconf="${myconf} --with-openssl=no"

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
		local myconf=
		has_version sys-libs/glibc || myconf="${myconf} --with-iconv"
		econf ${myconf} || die "idn econf failed"
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
