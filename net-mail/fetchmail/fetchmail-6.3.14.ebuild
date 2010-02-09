# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-mail/fetchmail/fetchmail-6.3.14.ebuild,v 1.1 2010/02/05 07:06:41 tove Exp $

EAPI=2

inherit multilib python eutils prefix

DESCRIPTION="the legendary remote-mail retrieval and forwarding utility"
HOMEPAGE="http://fetchmail.berlios.de"
SRC_URI="mirror://berlios/${PN}/${P}.tar.bz2"

LICENSE="GPL-2 public-domain"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="ssl nls kerberos hesiod tk"

RDEPEND="hesiod? ( net-dns/hesiod )
	ssl? ( >=dev-libs/openssl-0.9.6 )
	kerberos? ( virtual/krb5 >=dev-libs/openssl-0.9.6 )
	nls? ( virtual/libintl )
	!elibc_glibc? ( sys-libs/com_err )
	dev-lang/python[tk?]"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

RESTRICT=test

pkg_setup() {
	enewgroup ${PN}
	enewuser ${PN} -1 -1 /var/lib/${PN} ${PN}
}

src_prepare() {
	# this patch fixes bug #34788 (ticho@gentoo.org 2004-09-03)
	epatch "${FILESDIR}"/${PN}-6.2.5-broken-headers.patch

	# dont compile during src_install
	: > "${S}"/py-compile
}

src_configure() {
	local myconf=""
	use ssl \
		&& myconf="${myconf} --with-ssl=${EPREFIX}/usr" \
		|| myconf="${myconf} --without-ssl"
#	PYTHON=: \
		econf \
		--disable-dependency-tracking \
		--enable-RPA \
		--enable-NTLM \
		--enable-SDPS \
		$(use_enable nls) \
		$(use_with ssl) \
		$(use kerberos && echo "--with-ssl" ) \
		$(use_with kerberos gssapi) \
		$(use_with kerberos kerberos5) \
		$(use_with hesiod) \
		${myconf} || die "Configuration failed."
}

src_install() {
	# dir for pidfile
	dodir /var/run/${PN} || die "dodir failed"
	keepdir /var/run/${PN}
	use prefix || fowners ${PN}:${PN} /var/run/${PN} || die "fowners failed"

	# fetchmail's homedir (holds fetchmail's .fetchids)
	dodir /var/lib/${PN} || die "dodir failed"
	keepdir /var/lib/${PN}
	use prefix || fowners ${PN}:${PN} /var/lib/${PN} || die "fowners failed"
	fperms 700 /var/lib/${PN} || die "fperms failed"

	emake DESTDIR="${D}" install || die
	python_need_rebuild

	dohtml *.html

	dodoc FAQ FEATURES NEWS NOTES README README.NTLM README.SSL* TODO || die

	newinitd "${FILESDIR}"/fetchmail.new fetchmail || die
	newconfd "${FILESDIR}"/conf.d-fetchmail fetchmail || die

	docinto contrib
	local f
	for f in contrib/* ; do
		[ -f "${f}" ] && dodoc "${f}"
	done
}

pkg_postinst() {
	python_version
	python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages/fetchmailconf.py

	if ! has_version dev-lang/python[tk] ; then
		elog "Reinstall ${CATEGORY}/${PN} with USE=tk"
		elog "if you want to use fetchmailconf."
	fi

	elog "Please see /etc/conf.d/fetchmail if you want to adjust"
	elog "the polling delay used by the fetchmail init script."
}

pkg_postrm() {
	python_version
	python_mod_cleanup /usr/$(get_libdir)/python${PYVER}/site-packages
}
