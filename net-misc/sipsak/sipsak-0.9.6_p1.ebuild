# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/sipsak/sipsak-0.9.6_p1.ebuild,v 1.6 2009/09/23 19:44:49 patrick Exp $

IUSE="gnutls"

DESCRIPTION="small command line tool for testing SIP applications and devices"
HOMEPAGE="http://sipsak.org/"
SRC_URI="http://download.berlios.de/sipsak/${P/_p/-}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"

RDEPEND="gnutls? ( net-libs/gnutls )
		net-dns/c-ares"
#         ares? ( net-dns/c-ares )"

DEPEND="${RDEPEND}"

S=${WORKDIR}/${P/_p1/}

src_unpack() {
	unpack ${A}

	if [[ ${CHOST} == *-darwin* ]] ; then
		# On Darwin this breaks compilation, it seems -fstack-protector is
		# accepted by the compiler, but actually introduces a -lssp_nonshared
		# which causes linking failures
		sed -i -e 's/ssp_cc=yes/ssp_cc=no/' "${S}"/configure || die
	fi
}

src_compile() {
	econf $(use_enable gnutls) || die 'configure failed'
	emake || die 'make failed'
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc AUTHORS ChangeLog NEWS README TODO
}
