# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/vigra/vigra-1.6.0.ebuild,v 1.8 2010/03/09 13:01:41 ssuominen Exp $

EAPI=2

inherit eutils multilib

DESCRIPTION="C++ computer vision library with emphasize on customizable algorithms and data structures"
HOMEPAGE="http://kogs-www.informatik.uni-hamburg.de/~koethe/vigra/"
SRC_URI="http://kogs-www.informatik.uni-hamburg.de/~koethe/vigra/${P/-}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc fftw jpeg png tiff zlib test"

RDEPEND="png? ( media-libs/libpng )
	tiff? ( media-libs/tiff )
	jpeg? ( media-libs/jpeg )
	fftw? ( >=sci-libs/fftw-3 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S="${WORKDIR}/${P/-}"

MY_DOCDIR="usr/share/doc/${PF}"

pkg_setup() {
	local flag
	export usefail=""
	if use test
	then
		for flag in png tiff jpeg fftw
		do
			use $flag || usefail="$usefail $flag"
		done

		if [[ -n "$usefail" ]]
		then
			elog "USE=test enabled but the following use-flags are disabled:"
			elog "${usefail# }"
			elog "Tests will be skipped, please enable the other use-flags."
		fi
	fi
}

src_prepare() {
	epatch "${FILESDIR}/${P}-gcc44.patch"
	sed -i \
		-e 's:png_set_gray_1_2_4_to_8:png_set_expand_gray_1_2_4_to_8:g' \
		src/impex/png.cxx || die
}

src_configure() {
	./configure \
		--docdir="${ED}/${MY_DOCDIR}" \
		--prefix="${EPREFIX}/usr/" \
		$(use_with png) \
		$(use_with tiff) \
		$(use_with jpeg) \
		$(use_with zlib) \
		$(use_with fftw) \
		|| die "configure failed"
}

src_test() {
	if [[ -z "${usefail}" ]]
	then
		default
	fi
}

src_install() {
	emake libdir="${ED}/usr/$(get_libdir)" prefix="${ED}/usr" install || die "emake install failed"
	use doc || rm -Rf "${ED}/${MY_DOCDIR}"
	dodoc README.txt
}
