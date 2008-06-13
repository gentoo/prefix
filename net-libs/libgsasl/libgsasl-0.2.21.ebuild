# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libgsasl/libgsasl-0.2.21.ebuild,v 1.3 2007/09/30 21:40:39 ticho Exp $

EAPI="prefix"

DESCRIPTION="The GNU SASL library"
HOMEPAGE="http://www.gnu.org/software/gsasl/"
SRC_URI="http://josefsson.org/gsasl/releases/${P}.tar.gz"
LICENSE="LGPL-3"
SLOT="0"
# TODO: check http://www.gnu.org/software/gsasl/#dependencies for more
# 	optional external libraries.
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="idn kerberos nls static"
PROVIDE="virtual/gsasl"
DEPEND="virtual/libc
	nls? ( >=sys-devel/gettext-0.16.1 )
	kerberos? ( virtual/krb5 )
	idn? ( net-dns/libidn )"
RDEPEND="${DEPEND}
	!virtual/gsasl"

src_compile() {
	econf \
		$(use_enable kerberos gssapi) \
		$(use_enable kerberos kerberosv5) \
		$(use_with idn stringprep) \
		$(use_enable nls) \
		$(use_enable static) \
	|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "installation failed"
	dodoc ABOUT-NLS AUTHORS ChangeLog NEWS README README-alpha THANKS
}
