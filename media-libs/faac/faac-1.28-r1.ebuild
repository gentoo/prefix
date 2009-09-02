# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/faac/faac-1.28-r1.ebuild,v 1.7 2009/08/31 19:34:57 ranger Exp $

EAPI=2
inherit autotools eutils flag-o-matic

DESCRIPTION="Free MPEG-4 audio codecs by AudioCoding.com"
HOMEPAGE="http://www.audiocoding.com"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

RDEPEND=">=media-libs/libmp4v2-1.9.0"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${P}-external-libmp4v2.patch
	eautoreconf
	epunt_cxx

	# altivec stuff triggers a definition of bool which causes faac to fail
	# http://archives.postgresql.org/pgsql-hackers/2005-11/msg00104.php
	[[ ${CHOST} == *-darwin* ]] && \
		filter-flags "-faltivec" "-mabi=altivec" "-maltivec" "-mcpu=*"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README TODO
	dohtml docs/*.html
	insinto /usr/share/doc/${PF}/pdf
	doins docs/libfaac.pdf
}
