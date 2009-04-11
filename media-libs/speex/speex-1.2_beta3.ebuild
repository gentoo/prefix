# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/speex/speex-1.2_beta3.ebuild,v 1.9 2008/01/10 08:54:33 vapier Exp $

inherit autotools eutils flag-o-matic

MY_P=${P/_/}

DESCRIPTION="Audio compression format designed for speech."
HOMEPAGE="http://www.speex.org"
SRC_URI="http://downloads.xiph.org/releases/speex/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="ogg sse"

RDEPEND="ogg? ( >=media-libs/libogg-1 )"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-configure.patch
	eautoreconf
}

src_compile() {
	append-flags -D_FILE_OFFSET_BITS=64

	econf $(use_enable sse) $(use_enable ogg)
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" docdir="${EPREFIX}/usr/share/doc/${PF}" \
		install || die "emake install failed."

	dodoc AUTHORS ChangeLog NEWS README* TODO
}
