# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-mail/fetchmail/fetchmail-6.3.8-r2.ebuild,v 1.7 2008/06/16 18:34:59 jer Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="the legendary remote-mail retrieval and forwarding utility"
HOMEPAGE="http://fetchmail.berlios.de"
SRC_URI="http://download2.berlios.de/${PN}/${P}.tar.bz2"

LICENSE="GPL-2 public-domain"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="ssl nls ipv6 kerberos krb4 hesiod"

RDEPEND="hesiod? ( net-dns/hesiod )
	ssl? ( >=dev-libs/openssl-0.9.6 )
	kerberos? ( app-crypt/mit-krb5 )
	nls? ( virtual/libintl )
	!elibc_glibc? ( sys-libs/com_err )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# fixes DoS, #191154
	epatch "${FILESDIR}"/${P}-null-msg-pointer.patch

	# bug #227105
	epatch "${FILESDIR}"/${P}-resize-buffer.patch

	# this patch fixes bug #34788 (ticho@gentoo.org 2004-09-03)
	epatch "${FILESDIR}"/${PN}-6.2.5-broken-headers.patch
}

src_compile() {
	local myconf=""
	use ssl \
		&& myconf="${myconf} --with-ssl=${EPREFIX}/usr" \
		|| myconf="${myconf} --without-ssl"
	econf \
		--disable-dependency-tracking \
		--enable-RPA \
		--enable-NTLM \
		--enable-SDPS \
		$(use_enable nls) \
		$(use_enable ipv6 inet6) \
		$(use_with kerberos gssapi) $(use_with kerberos kerberos5) \
		$(use_with krb4 kerberos) \
		$(use_with hesiod) \
		${myconf} || die "Configuration failed."
	# wont compile reliably on smp (mkennedy@gentoo.org 2003-11-12)
	emake || die "Compilation failed."
}

src_install() {
	emake DESTDIR="${D}" install || die

	dohtml *.html

	dodoc FAQ FEATURES NEWS NOTES README README.NTLM README.SSL TODO

	cp "${FILESDIR}"/fetchmail .
	epatch "${FILESDIR}"/fetchmail-prefix.patch
	eprefixify fetchmail
	newinitd fetchmail fetchmail
	newconfd "${FILESDIR}"/conf.d-fetchmail fetchmail

	docinto contrib
	local f
	for f in contrib/*
	do
		[ -f "${f}" ] && dodoc "${f}"
	done
}

pkg_postinst() {
	if ! python -c "import Tkinter" >/dev/null 2>&1
	then
		elog
		elog "You will not be able to use fetchmailconf(1), because you"
		elog "don't seem to have Python with tkinter support."
		elog
		elog "If you want to be able to use fetchmailconf(1), do the following:"
		elog "  1.  Add 'tk' to the USE variable in /etc/make.conf."
		elog "  2.  (Re-)merge Python."
		elog
	fi

	elog "Please see /etc/conf.d/fetchmail if you want to adjust"
	elog "the polling delay used by the fetchmail init script."
}
