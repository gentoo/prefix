# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/gsasl/gsasl-1.1.ebuild,v 1.1 2009/04/25 23:03:37 patrick Exp $

DESCRIPTION="The GNU SASL client, server, and library"
HOMEPAGE="http://www.gnu.org/software/gsasl/"
SRC_URI="ftp://ftp.gnu.org/pub/gnu/gsasl/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
# TODO: check http://www.gnu.org/software/gsasl/#dependencies for more
# 	optional external libraries.
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="kerberos nls static doc"
PROVIDE="virtual/gsasl"
DEPEND="nls? ( sys-devel/gettext )
	kerberos? ( virtual/krb5 )"
RDEPEND="${DEPEND}
	!virtual/gsasl"

src_compile() {
	econf \
		--enable-client \
		--enable-server \
		$(use_enable kerberos gssapi) \
		$(use_enable nls) \
		$(use_enable static) \
	|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "einstall failed"
	dodoc AUTHORS ChangeLog NEWS README README-alpha THANKS
	doman doc/gsasl.1

	if use doc; then
		dodoc doc/*.{eps,ps,pdf}
		dohtml doc/*.html
		docinto examples
		dodoc examples/*.c
	fi
}
