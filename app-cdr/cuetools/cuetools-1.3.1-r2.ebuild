# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/cuetools/cuetools-1.3.1-r2.ebuild,v 1.1 2011/08/07 13:21:10 xarthisius Exp $

EAPI=4

inherit eutils flag-o-matic

DESCRIPTION="Utilities to manipulate and convert cue and toc files"
HOMEPAGE="http://developer.berlios.de/projects/cuetools/"
SRC_URI="mirror://berlios/${PN}/${P}.tar.gz
	mirror://gentoo/${P}-debian.patch.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="extras"

DEPEND="x86-interix? ( dev-libs/gnulib )"

DEPEND="sys-devel/bison
	sys-devel/flex"
RDEPEND="extras? (
		media-sound/vorbis-tools
		media-libs/flac
		media-sound/mp3info
	)"

src_prepare() {
	epatch "${WORKDIR}"/${P}-debian.patch \
		"${FILESDIR}"/${P}-flac.patch

	if [[ ${CHOST} == *-interix[35]* ]]; then
		append-flags -I"${EPREFIX}"/usr/$(get_libdir)/gnulib/include
		append-ldflags -L"${EPREFIX}"/usr/$(get_libdir)/gnulib/lib
		export LIBS="${LIBS} -lgnu"
	fi
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc AUTHORS NEWS README TODO
	use extras && dobin extras/cuetag.sh
	docinto extras
	dodoc extras/{cueconvert.cgi,*.txt}
}
