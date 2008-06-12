# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/speex/speex-1.1.12.ebuild,v 1.13 2008/01/10 15:00:52 drac Exp $

EAPI="prefix"

inherit eutils autotools libtool

DESCRIPTION="Speech encoding library"
HOMEPAGE="http://www.speex.org"
SRC_URI="http://downloads.xiph.org/releases/speex/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="ogg sse vorbis-psy"

RDEPEND="ogg? ( >=media-libs/libogg-1.0 )"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# This is needed to fix parallel make issues.
	# As this changes the Makefile.am, need to rebuild autotools.
	sed -i -e 's:\$(top_builddir)/libspeex/libspeex.la:libspeex.la:' \
		"${S}"/libspeex/Makefile.am

	epatch "${FILESDIR}/${P}-malloc.patch"

	eautoreconf

	# Better being safe
	elibtoolize
}

src_compile() {
	# FIXME: ogg autodetect only
	econf \
		$(use_enable vorbis-psy) \
		$(use_enable sse) \
		|| die "econf failed."
	emake || die "emake failed."
}

src_install () {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog README* TODO NEWS
}
