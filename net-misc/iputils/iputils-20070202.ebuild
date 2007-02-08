# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/iputils/iputils-20070202.ebuild,v 1.1 2007/02/03 22:34:16 vapier Exp $

EAPI="prefix"

inherit flag-o-matic eutils toolchain-funcs

DESCRIPTION="Network monitoring tools including ping and ping6"
HOMEPAGE="http://www.skbuff.net/iputils/"
SRC_URI="http://www.skbuff.net/iputils/iputils-s${PV}.tar.bz2"

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

S=${WORKDIR}/${PN}-s${PV}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-021109-gcc34.patch
	epatch "${FILESDIR}"/021109-uclibc-no-ether_ntohost.patch
	epatch "${FILESDIR}"/${PN}-20070202-makefile.patch
	epatch "${FILESDIR}"/${PN}-20060512-kernel-ifaddr.patch
	epatch "${FILESDIR}"/${PN}-20060512-linux-headers.patch

	use static && append-ldflags -static
	use ipv6 || sed -i -e 's:IPV6_TARGETS=:#IPV6_TARGETS=:' Makefile
}

src_compile() {
	tc-export CC
	emake || die "make main failed"

	# We include the extra check for docbook2html 
	# because when we emerge from a stage1/stage2, 
	# it may not exist #23156
	if use doc && type -p docbook2html ; then
		emake -j1 html man || die
	fi
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

	if use doc ; then
		rm -f doc/setkey.8
		use ipv6 \
			&& dosym ping.8 /usr/share/man/man8/ping6.8 \
			|| rm -f doc/*6.8
		doman doc/*.8

		dohtml doc/*.html
	fi
}
