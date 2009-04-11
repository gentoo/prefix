# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/snobol/snobol-1.1.ebuild,v 1.4 2008/01/29 21:31:52 grobian Exp $

DESCRIPTION="Phil Budne's port of Macro SNOBOL4 in C, for modern machines"
HOMEPAGE="http://www.snobol4.org/csnobol4/"
MY_PN="snobol4"
MY_P="${MY_PN}-${PV}"
#SRC_URI="ftp://ftp.snobol4.org/snobol4/${MY_P}.tar.gz ftp://ftp.ultimate.com/snobol/${MY_P}.tar.gz"
SRC_URI="mirror://snobol4/${MY_P}.tar.gz"
LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86-linux ~ppc-macos"
IUSE=""
DEPEND="sys-devel/gcc
		sys-devel/m4"
RDEPEND=""
S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	#export CFLAGS="-O0 -pipe"
	sed -i.orig -e '/autoconf/s:autoconf:./autoconf:g' \
		-e '/ADD_LDFLAGS/s/-ldb/-lndbm/' \
		${S}/configure
	echo "ADD_OPT([${CFLAGS}])" >>${S}/local-config
	echo "ADD_CPPFLAGS([-DUSE_STDARG_H])" >>${S}/local-config
	echo "ADD_CPPFLAGS([-DHAVE_STDARG_H])" >>${S}/local-config
	echo "BINDEST=${EPREFIX}/usr/bin/snobol4" >>${S}/local-config
	echo "MANDEST=${EPREFIX}/usr/share/man/man4/snobol4.1" >>${S}/local-config
	echo "SNOLIB_DIR=${EPREFIX}/usr/lib/snobol4" >>${S}/local-config
}

src_compile() {
	# WARNING
	# The configure script is NOT what you expect
	emake || die "emake failed"
	emake doc/snobol4.1 || die "emake doc/snobol4.1 failed"
}

src_install() {
	into /usr
	newbin xsnobol4 snobol4
	dodir /usr/lib/snobol4
	insinto /usr/lib/snobol4
	doins snolib.a snolib/bq.sno

	doman doc/*.1
	dohtml doc/*.html
	rm doc/*.html
	dodoc doc/*.ps doc/*.doc doc/*.txt doc/*.pdf
}
