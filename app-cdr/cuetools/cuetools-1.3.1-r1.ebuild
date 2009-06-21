# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/cuetools/cuetools-1.3.1-r1.ebuild,v 1.1 2009/06/20 22:10:05 flameeyes Exp $

inherit eutils flag-o-matic

DESCRIPTION="Utilities to manipulate and convert cue and toc files"
HOMEPAGE="http://developer.berlios.de/projects/cuetools/"
SRC_URI="mirror://berlios/${PN}/${P}.tar.gz
	mirror://gentoo/${P}-debian.patch.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="x86-interix? ( dev-libs/gnulib )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${WORKDIR}/${P}-debian.patch"

	if [[ ${CHOST} == *-interix[35]* ]]; then
		append-flags -I"${EPREFIX}"/usr/$(get_libdir)/gnulib/include
		append-ldflags -L"${EPREFIX}"/usr/$(get_libdir)/gnulib/lib
		export LIBS="${LIBS} -lgnu"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS NEWS README TODO || die
	docinto extras
	dodoc extras/{cue{convert.cgi,tag.sh},*.txt} || die
}
