# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/sipsak/sipsak-0.9.6_p1.ebuild,v 1.8 2010/10/28 12:33:26 ssuominen Exp $

EAPI=2

DESCRIPTION="small command line tool for testing SIP applications and devices"
HOMEPAGE="http://sipsak.org/"
SRC_URI="mirror://berlios/sipsak/${P/_p/-}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="gnutls"

RDEPEND="gnutls? ( net-libs/gnutls )
	net-dns/c-ares"
#	ares? ( net-dns/c-ares )"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${P/_p1}

src_prepare() {
	if [[ ${CHOST} == *-darwin* ]] ; then
		# On Darwin this breaks compilation, it seems -fstack-protector is
		# accepted by the compiler, but actually introduces a -lssp_nonshared
		# which causes linking failures
		sed -i -e 's/ssp_cc=yes/ssp_cc=no/' "${S}"/configure || die
	fi
}

src_configure() {
	econf \
		$(use_enable gnutls)
}

src_compile() {
	econf $(use_enable gnutls) || die 'configure failed'
	emake || die 'make failed'
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README TODO
}
