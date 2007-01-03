# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/apr/apr-0.9.7.ebuild,v 1.11 2006/05/18 18:14:40 vericgar Exp $

EAPI="prefix"

inherit flag-o-matic libtool

DESCRIPTION="Apache Portable Runtime Library"
HOMEPAGE="http://apr.apache.org/"
SRC_URI="mirror://apache/apr/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE="ipv6 urandom"
RESTRICT="test"

DEPEND=""

src_compile() {

	filter-ldflags -Wl,--as-needed --as-needed

	elibtoolize || die "elibtoolize failed"

	myconf="--datadir=${EPREFIX}/usr/share/apr-0"

	myconf="${myconf} $(use_enable ipv6)"
	myconf="${myconf} --enable-threads"
	myconf="${myconf} --enable-nonportable-atomics"
	if use urandom; then
		einfo "Using /dev/urandom as random device"
		myconf="${myconf} --with-devrandom=/dev/urandom"
	else
		einfo "Using /dev/random as random device"
		myconf="${myconf} --with-devrandom=/dev/random"
	fi

	econf ${myconf} || die
	emake || die
}

src_install() {
	make DESTDIR="${D}" installbuilddir=${EPREFIX}/usr/share/apr-0/build install || die

	# bogus values pointing at /var/tmp/portage
	sed -i -e "s:APR_SOURCE_DIR=.*:APR_SOURCE_DIR=${EPREFIX}/usr/share/apr-0:g" "${ED}"/usr/bin/apr-config
	sed -i -e "s:APR_BUILD_DIR=.*:APR_BUILD_DIR=${EPREFIX}/usr/share/apr-0/build:g" "${ED}"/usr/bin/apr-config

	sed -i -e "s:apr_builddir=.*:apr_builddir=${EPREFIX}/usr/share/apr-0/build:g" "${ED}"/usr/share/apr-0/build/apr_rules.mk
	sed -i -e "s:apr_builders=.*:apr_builders=${EPREFIX}/usr/share/apr-0/build:g" "${ED}"/usr/share/apr-0/build/apr_rules.mk

	cp -p build/*.awk ${ED}/usr/share/apr-0/build
	cp -p build/*.sh ${ED}/usr/share/apr-0/build
	cp -p build/*.pl ${ED}/usr/share/apr-0/build

	dodoc CHANGES LICENSE NOTICE
}
