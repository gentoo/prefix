# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/vigra/vigra-1.5.0-r1.ebuild,v 1.5 2008/08/11 18:45:37 bluebird Exp $

inherit multilib

DESCRIPTION="C++ computer vision library with emphasize on customizable algorithms and data structures"
HOMEPAGE="http://kogs-www.informatik.uni-hamburg.de/~koethe/vigra/"
SRC_URI="http://kogs-www.informatik.uni-hamburg.de/~koethe/vigra/${P/-}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE="doc fftw jpeg png tiff zlib"

RDEPEND="png? ( media-libs/libpng )
	tiff? ( media-libs/tiff )
	jpeg? ( media-libs/jpeg )
	fftw? ( >=sci-libs/fftw-3 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S="${WORKDIR}/${P/-}"

MY_DOCDIR="usr/share/doc/${PF}"

src_compile() {
	./configure \
		--prefix="${EPREFIX}/usr/" \
		--docdir="${ED}/${MY_DOCDIR}" \
		$(use_with png) \
		$(use_with tiff) \
		$(use_with jpeg) \
		$(use_with zlib) \
		$(use_with fftw) \
	|| die "configure failed"
	emake || die "emake failed"
}

src_install() {
	emake libdir="${ED}/usr/$(get_libdir)" prefix="${ED}/usr" install || die "emake install failed"
	use doc || rm -Rf "${ED}/${MY_DOCDIR}"
	dodoc README.txt
}
