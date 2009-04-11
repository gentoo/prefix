# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/faac/faac-1.28.ebuild,v 1.1 2009/02/19 23:13:34 aballier Exp $

inherit libtool eutils autotools flag-o-matic

DESCRIPTION="Free MPEG-4 audio codecs by AudioCoding.com"
HOMEPAGE="http://www.audiocoding.com/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""
RDEPEND="media-libs/libmp4v2"
DEPEND="${RDEPEND}
	!<media-libs/faad2-2.0-r3"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PN}-1.26-external-libmp4v2.patch"

	eautoreconf
	elibtoolize
	epunt_cxx

	# altivec stuff triggers a definition of bool which causes faac to fail
	# http://archives.postgresql.org/pgsql-hackers/2005-11/msg00104.php
	[[ ${CHOST} == *-darwin* ]] && \
		filter-flags "-faltivec" "-mabi=altivec" "-maltivec" "-mcpu=*"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README TODO docs/libfaac.pdf
	dohtml docs/*
}
