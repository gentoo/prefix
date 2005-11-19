# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/apr-util/apr-util-1.1.2.ebuild,v 1.6 2005/10/10 03:23:15 matsuu Exp $

EAPI="prefix"

inherit multilib

DESCRIPTION="Apache Portable Runtime Library"
HOMEPAGE="http://apr.apache.org/"
SRC_URI="mirror://apache/apr/${P}.tar.gz"

LICENSE="Apache-2.0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc-macos ~ppc64 ~s390 ~sh ~sparc ~x86"
SLOT="1"
RESTRICT="test"

IUSE="berkdb gdbm ldap"

DEPEND="dev-libs/expat
	>=dev-libs/apr-1.1.0
	berkdb? ( sys-libs/db )
	gdbm? ( sys-libs/gdbm )
	ldap? ( =net-nds/openldap-2* )"

src_compile() {
	myconf=""

	if use ldap; then
		myconf="${myconf} --with-ldap"
	fi

	if use berkdb; then
		if has_version '=sys-libs/db-4.2*'; then
			myconf="${myconf} --with-dbm=db42
			--with-berkeley-db=${PREFIX}/usr/include/db4.2:/usr/$(get_libdir)"
		elif has_version '=sys-libs/db-4*'; then
			myconf="${myconf} --with-dbm=db4
			--with-berkeley-db=${PREFIX}/usr/include/db4:${PREFIX}/usr/$(get_libdir)"
		elif has_version '=sys-libs/db-3*'; then
			myconf="${myconf} --with-dbm=db3
			--with-berkeley-db=${PREFIX}/usr/include/db3:${PREFIX}/usr/$(get_libdir)"
		elif has_version '=sys-libs/db-2'; then
			myconf="${myconf} --with-dbm=db2
			--with-berkely-db=${PREFIX}/usr/include/db2:${PREFIX}/usr/$(get_libdir)"
		fi
	fi

	./configure \
		$(with_prefix) \
		--host=${CHOST} \
		$(with_mandir) \
		$(with_infodir)\
		$(with_datadir /usr/share/apr-util-1) \
		$(with_sysconfdir) \
		$(with_localstatedir) \
		--with-apr=${PREFIX}/usr \
		$myconf || die

	emake || die
}

src_install() {
	einstall installbuilddir=${D}/usr/share/apr-util-1/build

	#bogus values pointing at /var/tmp/portage
	sed -i -e "s:APU_SOURCE_DIR=.*:APU_SOURCE_DIR=:g' ${D}/usr/bin/apu-1-config"
	sed -i -e "s:APU_BUILD_DIR=.*:APU_BUILD_DIR=${PREFIX}/usr/share/apr-util-1/build:g" ${D}/usr/bin/apu-1-config

	dodoc CHANGES LICENSE NOTICE
}
