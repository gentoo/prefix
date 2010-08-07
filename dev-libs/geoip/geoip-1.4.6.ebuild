# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/geoip/geoip-1.4.6.ebuild,v 1.12 2010/07/21 21:12:01 ssuominen Exp $

EAPI=2
inherit libtool

MY_P=${P/geoip/GeoIP}
MY_P=${MY_P/_}
DESCRIPTION="easily lookup countries by IP addresses, even when Reverse DNS entries don't exist"
HOMEPAGE="http://www.maxmind.com/geoip/api/c.shtml"
SRC_URI="http://www.maxmind.com/download/geoip/api/c/${MY_P}.tar.gz"

# GPL-2 for md5.c - part of libGeoIPUpdate, MaxMind for GeoLite Country db
LICENSE="LGPL-2.1 GPL-2 MaxMind"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
IUSE="perl-geoipupdate"

DEPEND=""
RDEPEND="perl-geoipupdate? ( dev-perl/PerlIO-gzip
	dev-perl/libwww-perl )"

S=${WORKDIR}/${MY_P}

src_prepare() {
	sed -e "s:usr local share GeoIP:usr share GeoIP:" \
		-e "s:usr local etc:etc:" -i apps/geoipupdate-pureperl.pl

	elibtoolize # FreeBSD requires this
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	use perl-geoipupdate && { dobin apps/geoipupdate-pureperl.pl || die; }
	dodoc AUTHORS ChangeLog README TODO conf/GeoIP.conf.default || die
	rm "${ED}/etc/GeoIP.conf.default"
}
