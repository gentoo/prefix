# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/iputils/iputils-021109-r3.ebuild,v 1.26 2006/08/20 07:26:41 vapier Exp $

EAPI="prefix"

inherit flag-o-matic eutils toolchain-funcs

DESCRIPTION="Network monitoring tools including ping and ping6"
HOMEPAGE="ftp://ftp.inr.ac.ru/ip-routing"
SRC_URI="ftp://ftp.inr.ac.ru/ip-routing/${PN}-ss${PV}-try.tar.bz2
	http://ftp.iasi.roedu.net/mirrors/ftp.inr.ac.ru/ip-routing/${PN}-ss${PV}-try.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86"
IUSE="static ipv6 doc"

DEPEND="virtual/os-headers
	doc? (
		app-text/openjade
		dev-perl/SGMLSpm
		app-text/docbook-sgml-dtd
		app-text/docbook-sgml-utils
	)"
RDEPEND=""

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-gcc34.patch
	epatch "${FILESDIR}"/${P}-gcc4.patch
	epatch "${FILESDIR}"/${PV}-no-pfkey-search.patch
	epatch "${FILESDIR}"/${PV}-ipg-linux-2.6.patch #71756
	epatch "${FILESDIR}"/${PV}-syserror.patch
	epatch "${FILESDIR}"/${PV}-uclibc-no-ether_ntohost.patch
	epatch "${FILESDIR}"/${P}-bindnow.patch #77526
	epatch "${FILESDIR}"/${P}-ipv6-updates.patch #134751
	# make iputils work with newer glibc snapshots
	epatch "${FILESDIR}"/${P}-linux-udp-header.patch

	use static && append-ldflags -static
	sed -i \
		-e "/^CCOPT=/s:-O2:${CFLAGS}:" \
		-e "/^CC=/s:.*::" \
		-e '/^all:/s:check-kernel::' \
		-e 's:-I$(KERNEL_INCLUDE)::' \
		-e 's:-I/usr/src/linux/include::' \
		Makefile \
		|| die "sed Makefile failed"
	use ipv6 || sed -i -e 's:IPV6_TARGETS=:#IPV6_TARGETS=:' Makefile
}

src_compile() {
	tc-export CC AR
	emake || die "make main failed"

	# We include the extra check for docbook2html 
	# because when we emerge from a stage1/stage2, 
	# it may not exist #23156
	if use doc && type -p docbook2html ; then
		emake -j1 html || die
	fi
	emake -j1 man || die "make man failed"
}

src_install() {
	into /
	dobin ping || die "ping"
	use ipv6 && dobin ping6
	dosbin arping || die "arping"
	into /usr
	dosbin tracepath || die "tracepath"
	use ipv6 && dosbin trace{path,route}6
	dosbin clockdiff rarpd rdisc ipg tftpd || die "misc sbin"

	fperms 4711 /bin/ping
	use ipv6 && fperms 4711 /bin/ping6 /usr/sbin/traceroute6

	dodoc INSTALL RELNOTES

	rm -f doc/setkey.8
	use ipv6 \
		&& dosym ping.8 /usr/share/man/man8/ping6.8 \
		|| rm -f doc/*6.8
	doman doc/*.8

	use doc && dohtml doc/*.html
}
