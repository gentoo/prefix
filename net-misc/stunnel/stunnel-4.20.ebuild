# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/stunnel/stunnel-4.20.ebuild,v 1.12 2007/11/03 16:00:15 drac Exp $

EAPI="prefix"

inherit ssl-cert eutils flag-o-matic

DESCRIPTION="TLS/SSL - Port Wrapper"
HOMEPAGE="http://stunnel.mirt.net/"
SRC_URI="http://www.stunnel.org/download/stunnel/src/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE="ipv6 selinux tcpd"

DEPEND="tcpd? ( sys-apps/tcp-wrappers )
	>=dev-libs/openssl-0.9.6j"
RDEPEND="${DEPEND}
	selinux? ( sec-policy/selinux-stunnel )"

src_unpack() {
	unpack ${A}
	# Hack away generation of certificate
	sed -i s/^install-data-local:/do-not-run-this:/ "${S}"/tools/Makefile.in
}

src_compile() {
	local myconf=""
	# Don't shoot me for doing this! The stunnel configure script is broke and
	# doesn't honor --disable-foo
	if use ipv6 ; then
		myconf="${myconf} --enable-ipv6"
	fi
	if ! use tcpd ; then
		myconf="${myconf} --disable-libwrap"
	fi
	econf ${myconf} --with-ssl="${EPREFIX}"/usr || die "econf died"
	emake || die "emake died"
}

src_install() {
	make DESTDIR=${D} install || die "make install failed"
	rm -rf ${ED}/usr/share/doc/${PN}
	rm -f ${ED}/{etc/stunnel/stunnel.conf-sample,usr/sbin/stunnel3}
	rm -f ${ED}/usr/share/man/man8/{stunnel.fr.8,stunnel.pl.8}

	dodoc AUTHORS BUGS CREDITS INSTALL NEWS PORTS README TODO ChangeLog \
		doc/en/transproxy.txt
	dohtml doc/stunnel.html doc/en/VNC_StunnelHOWTO.html tools/ca.html \
		tools/importCA.html

	insinto /etc/stunnel
	newins ${FILESDIR}/stunnel.conf stunnel.conf
	newinitd ${FILESDIR}/stunnel.rc6 stunnel
	# Check if there's currently an cert already there
	if [ ! -f /etc/stunnel/stunnel.key ]; then
		docert stunnel
	fi

	keepdir /var/run/stunnel
}

pkg_postinst() {
	enewgroup stunnel
	enewuser stunnel -1 -1 -1 stunnel

	chown stunnel:stunnel ${EROOT}/var/run/stunnel
	chown stunnel:stunnel ${EROOT}/etc/stunnel/stunnel.{conf,crt,csr,key,pem}
	chmod 0640 ${EROOT}/etc/stunnel/stunnel.{conf,crt,csr,key,pem}

	if [ ! -z "$(egrep '/etc/stunnel/stunnel.pid' \
		${EROOT}/etc/stunnel/stunnel.conf )" ] ; then

		ewarn "As of stunnel-4.09, the pid file will be located in /var/run/stunnel."
		ewarn "Please stop stunnel, etc-update, and start stunnel back up to ensure"
		ewarn "the update takes place"
		ewarn ""
		ewarn "The new location will be /var/run/stunnel/stunnel.pid"
		ebeep 3
		epause 3
	fi
}
