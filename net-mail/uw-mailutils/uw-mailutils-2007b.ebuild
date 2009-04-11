# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-mail/uw-mailutils/uw-mailutils-2007b.ebuild,v 1.8 2008/09/20 10:02:50 dertobi123 Exp $

inherit eutils flag-o-matic

MY_P="imap-${PV}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="Mail utilities from the UW"
HOMEPAGE="http://www.washington.edu/imap/"
SRC_URI="ftp://ftp.cac.washington.edu/imap/${MY_P}.tar.Z"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="virtual/libc
	!<mail-client/pine-4.64-r1"
RDEPEND="${DEPEND}
	!<net-mail/uw-imap-${PV}"

src_unpack() {
	unpack ${A}
	chmod -R ug+w "${S}"

	cd "${S}"

	epatch "${FILESDIR}/${PN}-2004g.patch" || die "epatch failed"

	sed -i -e "s|\`cat \$C/CFLAGS\`|${CFLAGS}|g" \
		src/mailutil/Makefile \
		src/mtest/Makefile || die "sed failed patching Makefile CFLAGS."

	append-flags -fPIC
}

src_compile() {
	if [[ ${CHOST} == *-darwin* ]] ; then
		yes | make osx EXTRACFLAGS="${CFLAGS}" \
		    SPECIALS="SSLDIR=${EPREFIX}/etc/ssl SSLINCLUDE=${EPREFIX}/usr/include/openssl SSLLIB=${EPREFIX}/usr/lib" SSLTYPE=none || die
	else
		local port=slx
		use elibc_FreeBSD && port=bsf
		yes | make "${port}" EXTRACFLAGS="${CFLAGS}" SSLTYPE=none || die
	fi
}

src_install() {
	into /usr
	dobin mailutil/mailutil mtest/mtest
	doman src/mailutil/mailutil.1
}
