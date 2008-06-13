# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/gsasl/gsasl-0.2.21.ebuild,v 1.5 2008/02/03 16:20:00 grobian Exp $

EAPI="prefix"

DESCRIPTION="The GNU SASL client, server, and library"
HOMEPAGE="http://www.gnu.org/software/gsasl/"
SRC_URI="http://josefsson.org/gsasl/releases/${P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
# TODO: check http://www.gnu.org/software/gsasl/#dependencies for more
# 	optional external libraries.
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="doc gnutls idn kerberos nls static"
PROVIDE="virtual/gsasl"
DEPEND="virtual/libc
	nls? ( >=sys-devel/gettext-0.16.1 )
	kerberos? ( virtual/krb5 )
	idn? ( net-dns/libidn )
	gnutls? ( net-libs/gnutls )"
RDEPEND="${DEPEND}
	!virtual/gsasl"

src_compile() {
	econf \
		--enable-client \
		--enable-server \
		$(use_enable kerberos gssapi) \
		$(use_enable kerberos kerberosv5) \
		$(use_with idn stringprep) \
		$(use_enable nls) \
		$(use_with gnutls) \
		$(use_enable static) \
	|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "einstall failed"
	dodoc ABOUT-NLS AUTHORS ChangeLog NEWS README README-alpha THANKS
	doman doc/gsasl.1

	if use doc; then
		dodoc doc/*.{eps,ps,pdf}
		dohtml doc/*.html
		docinto examples
		dodoc examples/*.c
	fi
}
