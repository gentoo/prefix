# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/ca-certificates/ca-certificates-20050804.ebuild,v 1.6 2007/02/03 01:37:20 vapier Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Common CA Certificates PEM files"
HOMEPAGE="http://www.cacert.org/"
SRC_URI="mirror://debian/pool/main/c/${PN}/${PN}_${PV}_all.deb"

LICENSE="freedist"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE=""

DEPEND="kernel_AIX? ( app-arch/deb2targz )" # platforms like AIX don't have a good ar
RDEPEND="dev-libs/openssl"

S=${WORKDIR}

src_install() {
	mkdir -p "${ED}"
	cd "${ED}"
	tar zxf "${S}"/data.tar.gz || die "installing data failed"

	(
	cd "${ED}"/usr/share/ca-certificates
	find . -name '*.crt' | sort | cut -b3-
	) > etc/ca-certificates.conf

	mv "${ED}"/usr/share/doc/{ca-certificates,${PF}} || die
	prepalldocs
	# dirty prefix job (someone gotta do it...)
	sed -i -e "1s|^.*$|#${EPREFIX}/bin/bash -e|" \
		-e "/^\(CERTSCONF\|CERTSDIR\)=/s|=|=\"${EPREFIX}\"|" \
		-e "s|^cd /etc/ssl/certs$|cd \"${EPREFIX}\"/etc/ssl/certs|" \
		usr/sbin/update-ca-certificates || die "Can't prefixify"
}

pkg_postinst() {
	[[ ${ROOT} != "/" ]] && return 0
	update-ca-certificates
}
