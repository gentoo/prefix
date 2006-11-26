# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/net-tools/net-tools-1.60-r12.ebuild,v 1.10 2006/11/15 12:48:01 corsair Exp $

EAPI="prefix"

inherit flag-o-matic toolchain-funcs eutils

PVER="1.4"
DESCRIPTION="Standard Linux networking tools"
HOMEPAGE="http://sites.inka.de/lina/linux/NetTools/"
SRC_URI="http://www.tazenda.demon.co.uk/phil/net-tools/${P}.tar.bz2
	mirror://gentoo/${P}-patches-${PVER}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86"
IUSE="nls static"

RDEPEND="!sys-apps/mii-diag
	!net-misc/etherwake"
DEPEND="nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${WORKDIR}"/patch/*.patch
	cp "${WORKDIR}"/extra/config.{h,make} . || die
	mkdir include/linux
	cp "${WORKDIR}"/extra/*.h include/linux/
	mv "${WORKDIR}"/extra/ethercard-diag/ "${S}"/ || die

	if use static ; then
		append-flags -static
		append-ldflags -static
	fi

	sed -i \
		-e "/^COPTS =/s:=:=${CFLAGS}:" \
		-e "/^LOPTS =/s:=:=${LDFLAGS}:" \
		Makefile || die "sed FLAGS Makefile failed"

	if ! use nls ; then
		sed -i \
			-e '/define I18N/s:1$:0:' config.h \
			|| die "sed config.h failed"
		sed -i \
			-e '/^I18N=/s:1$:0:' config.make \
			|| die "sed config.make failed"
	fi
}

src_compile() {
	tc-export CC
	emake libdir || die "emake libdir failed"
	emake || die "emake failed"
	emake -C ethercard-diag || die "emake ethercard-diag failed"

	if use nls ; then
		emake i18ndir || die "emake i18ndir failed"
	fi
}

src_install() {
	make BASEDIR="${ED}" install || die "make install failed"
	make -C ethercard-diag DESTDIR="${ED}" install || die "make install ethercard-diag failed"
	mv "${ED}"/usr/share/man/man8/ether{,-}wake.8
	mv "${ED}"/usr/sbin/mii-diag "${ED}"/sbin/ || die "mv mii-diag failed"
	mv "${ED}"/bin/* "${ED}"/sbin/ || die "mv bin to sbin failed"
	mv "${ED}"/sbin/{hostname,domainname,netstat,dnsdomainname,ypdomainname,nisdomainname} "${ED}"/bin/ \
		|| die "mv sbin to bin failed"
	dodir /usr/bin
	dosym /bin/hostname /usr/bin/hostname

	dodoc README README.ipv6 TODO
}
