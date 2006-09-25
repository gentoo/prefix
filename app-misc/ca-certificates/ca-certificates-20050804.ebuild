# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/ca-certificates/ca-certificates-20050804.ebuild,v 1.3 2006/03/30 14:36:07 flameeyes Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Common CA Certificates PEM files"
HOMEPAGE="http://www.cacert.org/"
SRC_URI="mirror://debian/pool/main/c/${PN}/${PN}_${PV}_all.deb"

LICENSE="freedist"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

RDEPEND="dev-libs/openssl"

S=${WORKDIR}

src_unpack() {
	echo ">>> Unpacking ${A} to ${PWD}"
	cp "${DISTDIR}"/${A} .
	ar x ${A} || die "failure unpacking ${A}"
}

src_install() {
	mkdir -p "${D}"
	cd "${D}"
	tar zxf "${S}"/data.tar.gz || die "installing data failed"
	find "${D}"/usr/share/ca-certificates -name '*.crt' -printf '%P\n' \
		| sort > etc/ca-certificates.conf
}

pkg_postinst() {
	[[ ${ROOT} != "/" ]] && return 0
	update-ca-certificates
}
