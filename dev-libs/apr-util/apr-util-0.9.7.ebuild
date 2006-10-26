# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/apr-util/apr-util-0.9.7.ebuild,v 1.12 2006/06/04 13:23:34 chtekk Exp $

EAPI="prefix"

inherit eutils libtool db-use

DESCRIPTION="Apache Portable Runtime Library"
HOMEPAGE="http://apr.apache.org/"
SRC_URI="mirror://apache/apr/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="berkdb gdbm ldap"
RESTRICT="test"

DEPEND="dev-libs/expat
	~dev-libs/apr-0.9.7
	berkdb? ( =sys-libs/db-4* )
	gdbm? ( sys-libs/gdbm )
	ldap? ( =net-nds/openldap-2* )"

src_compile() {
	elibtoolize || die "elibtoolize failed"

	local myconf=""

	use ldap && myconf="${myconf} --with-ldap"
	myconf="${myconf} $(use_with gdbm)"

	if use berkdb; then
		dbver="$(db_findver sys-libs/db)" || die "Unable to find db version"
		dbver="$(db_ver_to_slot "$dbver")"
		dbver="${dbver/\./}"
		# grobian: this results in 44, and the max supported version in the
		# configure script is 43, so skip it, it seems to work fine without
#		myconf="${myconf} --with-dbm=db${dbver}
		myconf="${myconf}
		--with-berkeley-db=$(db_includedir):${EPREFIX}/usr/$(get_libdir)"
	else
		myconf="${myconf} --without-berkeley-db"
	fi

	econf \
		--datadir=${EPREFIX}/usr/share/apr-util-0 \
		--with-apr=${EPREFIX}/usr \
		--with-expat=${EPREFIX}/usr \
		$myconf || die

	emake || die
}

src_install() {
	make DESTDIR="${D}" installbuilddir=/usr/share/apr-util-0/build install || die

	#bogus values pointing at /var/tmp/portage
	sed -i -e "s:APU_SOURCE_DIR=.*:APU_SOURCE_DIR=:g" ${ED}/usr/bin/apu-config
	sed -i -e "s:APU_BUILD_DIR=.*:APU_BUILD_DIR=${EPREFIX}/usr/share/apr-util-0/build:g" ${ED}/usr/bin/apu-config

	dodoc CHANGES NOTICE

	# Will install as portage user when using userpriv. Fixing
	chown -R root:0 ${ED}/usr/include/apr-0/
}
