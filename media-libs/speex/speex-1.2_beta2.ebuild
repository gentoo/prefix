# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/speex/speex-1.2_beta2.ebuild,v 1.6 2007/11/06 19:20:09 corsair Exp $

EAPI="prefix"

inherit autotools eutils flag-o-matic

MY_P=${P/_/}

DESCRIPTION="Audio compression format designed for speech."
HOMEPAGE="http://www.speex.org"
SRC_URI="http://downloads.xiph.org/releases/speex/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE="doc ogg sse vorbis-psy wideband"

RDEPEND="ogg? ( >=media-libs/libogg-1 )"
DEPEND="${RDEPEND}"

S="${WORKDIR}"/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-optional-ogg-and-cflags.patch
	eautoreconf
	_elibtoolize
}

src_compile() {
	# Add largefile support.
	append-flags -D_FILE_OFFSET_BITS=64

	econf $(use_enable vorbis-psy) $(use_enable sse) \
		$(use_enable ogg) $(use_enable wideband)
	emake || die "emake failed."
}

src_install () {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README* TODO

	# Install manual.pdf to correct location.
	rm -f "${ED}"/usr/share/doc/speex-1.2beta2/manual.pdf
	use doc && dodoc doc/manual.pdf
}
