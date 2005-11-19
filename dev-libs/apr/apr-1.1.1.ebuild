# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/apr/apr-1.1.1.ebuild,v 1.5 2005/09/29 21:14:42 matsuu Exp $

EAPI="prefix"

inherit flag-o-matic

DESCRIPTION="Apache Portable Runtime Library"
HOMEPAGE="http://apr.apache.org/"
SRC_URI="mirror://apache/apr/${P}.tar.gz"

LICENSE="Apache-2.0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc-macos ~ppc64 ~s390 ~sh ~sparc ~x86"
SLOT="1"
IUSE="ipv6"
RESTRICT="test"

DEPEND=">=sys-apps/sed-4"

# this function shall maybe go into flag-o-matic.eclass
lfs-flags() {
	echo -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE
}

src_compile() {
	myconf=""

	myconf="${myconf} $(use_enable ipv6 ipv6)"
	myconf="${myconf} --enable-threads"
	myconf="${myconf} --enable-nonportable-atomics"

	append-lfs-flags

	./configure \
	       $(with_prefix) \
	       --host=${CHOST} \
	       $(with_mandir) \
	       $(with_infodir) \
	       $(with_datadir /usr/share/apr-1) \
	       $(with_sysconfdir) \
	       $(with_localstatedir)\
	       $myconf || die

	emake || die
}

src_install() {
	einstall installbuilddir=${D}/usr/share/apr-1/build

	#bogus values pointing at /var/tmp/portage
	sed -i -e "s:APR_SOURCE_DIR=.*:APR_SOURCE_DIR=${PREFIX}/usr/share/apr-1:g" ${D}/usr/bin/apr-1-config
	sed -i -e "s:APR_BUILD_DIR=.*:APR_BUILD_DIR=${PREFIX}/usr/share/apr-1/build:g" ${D}/usr/bin/apr-1-config
	sed -i -e "s:installbuilddir=.*:installbuilddir=${PREFIX}/usr/share/apr-1/build:g" ${D}/usr/bin/apr-1-config
	sed -i -e "s:apr_builddir=.*:apr_builddir=${PREFIX}/usr/share/apr-1/build:g" ${D}/usr/share/apr-1/build/apr_rules.mk
	sed -i -e "s:apr_builders=.*:apr_builders=${PREFIX}/usr/share/apr-1/build:g" ${D}/usr/share/apr-1/build/apr_rules.mk
	sed -i -e "s:CPPFLAGS=\"\\(.*\\)\":CPPFLAGS=\"\\1 `lfs-flags`\":" ${D}/usr/bin/apr-1-config

	cp -p build/*.awk ${D}/usr/share/apr-1/build
	cp -p build/*.sh ${D}/usr/share/apr-1/build
	cp -p build/*.pl ${D}/usr/share/apr-1/build

	dodoc CHANGES LICENSE NOTICE
}
