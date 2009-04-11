# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/ilmbase/ilmbase-1.0.1.ebuild,v 1.10 2009/03/11 19:45:06 armin76 Exp $

inherit libtool eutils

DESCRIPTION="OpenEXR ILM Base libraries"
HOMEPAGE="http://openexr.com/"
SRC_URI="http://download.savannah.nongnu.org/releases/openexr/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

DEPEND="!<media-libs/openexr-1.5.0"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PN}-1.0.0-asneeded.patch"

	# gcc-apple-4.2.1 dies on this
	sed -i -e "s/-Wno-long-double//g" "${S}/configure" || die

	# Sane versioning on FreeBSD - please don't remove elibtoolize
	elibtoolize
}

src_install () {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc AUTHORS ChangeLog NEWS README
}
