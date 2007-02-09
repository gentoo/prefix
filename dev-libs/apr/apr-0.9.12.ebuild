# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/apr/apr-0.9.12.ebuild,v 1.15 2006/10/18 16:10:41 uberlord Exp $

EAPI="prefix"

inherit eutils flag-o-matic libtool

DESCRIPTION="Apache Portable Runtime Library"
HOMEPAGE="http://apr.apache.org/"
SRC_URI="mirror://apache/apr/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE="ipv6 urandom"
RESTRICT="test"

DEPEND=""

src_unpack() {

	unpack ${A} || die
	cd ${S} || die

	epatch ${FILESDIR}/apr-0.9.12-linking.patch
	elibtoolize || die "elibtoolize failed"

}

src_compile() {

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

	# We pre-load the cache with the correct answer!  This avoids
	# it violating the sandbox.  This may have to be changed for
	# non-Linux systems or if sem_open changes on Linux.  This
	# hack is built around documentation in /usr/include/semaphore.h
	# and the glibc (pthread) source
	# See bugs 24215 and 133573
	echo 'ac_cv_func_sem_open=${ac_cv_func_sem_open=no}' >> ${S}/config.cache

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

	# This file is only used on AIX systems, which gentoo is not,
	# and causes collisions between the SLOTs, so kill it
	rm ${ED}/usr/$(get_libdir)/apr.exp

}
