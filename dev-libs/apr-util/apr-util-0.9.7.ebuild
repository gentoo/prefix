# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/apr-util/apr-util-0.9.7.ebuild,v 1.1 2005/10/22 21:07:32 vericgar Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Apache Portable Runtime Library"
HOMEPAGE="http://apr.apache.org/"
SRC_URI="mirror://apache/apr/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc-macos ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="berkdb gdbm ldap"
RESTRICT="test"

DEPEND="dev-libs/expat
	~dev-libs/apr-0.9.7
	berkdb? ( sys-libs/db )
	gdbm? ( sys-libs/gdbm )
	ldap? ( =net-nds/openldap-2* )"

src_unpack() {
	unpack ${A} || die "unpack"

	cd ${S} || die
}

src_compile() {
	local myconf=""
	if use ldap; then
		myconf="${myconf} --with-ldap"
	fi

	if use berkdb; then
		if has_version '=sys-libs/db-4.2*'; then
			myconf="${myconf} --with-dbm=db42
			--with-berkeley-db=${PREFIX}/usr/include/db4.2:${PREFIX}/usr/$(get_libdir)"
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

	econf \
		--datadir=${PREFIX}/usr/share/apr-util-0 \
		--with-apr=${PREFIX}/usr \
		--with-expat=${PREFIX}/usr \
		$myconf || die

	emake || die
}

src_install() {
	make DESTDIR="${DEST}" installbuilddir=/usr/share/apr-util-0/build install || die

	#bogus values pointing at /var/tmp/portage
	sed -i -e "s:APU_SOURCE_DIR=.*:APU_SOURCE_DIR=:g" ${D}/usr/bin/apu-config
	sed -i -e "s:APU_BUILD_DIR=.*:APU_BUILD_DIR=${PREFIX}/usr/share/apr-util-0/build:g" ${D}/usr/bin/apu-config

	dodoc CHANGES NOTICE

	# Will install as portage user when using userpriv. Fixing
	chown -R root:0 ${D}/usr/include/apr-0/
}
