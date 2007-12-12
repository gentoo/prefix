# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libvorbis/libvorbis-1.2.0.ebuild,v 1.11 2007/12/11 23:38:03 vapier Exp $

EAPI="prefix"

inherit libtool flag-o-matic eutils toolchain-funcs

DESCRIPTION="the Ogg Vorbis sound file format library"
HOMEPAGE="http://xiph.org/vorbis"
SRC_URI="http://downloads.xiph.org/releases/vorbis/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="doc"

RDEPEND=">=media-libs/libogg-1"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"

	elibtoolize

	epunt_cxx #74493

	# Insane.
	sed -i -e "s:-O20::g" configure
}

src_compile() {
	# gcc-3.4 and k6 with -ftracer causes code generation problems #49472
	if [[ "$(gcc-major-version)$(gcc-minor-version)" == "34" ]]; then
		is-flag -march=k6* && filter-flags -ftracer
		is-flag -mtune=k6* && filter-flags -ftracer
		replace-flags -Os -O2
	fi

	econf
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."

	rm -rf "${ED}"/usr/share/doc/${P}

	dodoc AUTHORS CHANGES README todo.txt

	if use doc; then
		docinto txt
		dodoc doc/*.txt
		dohtml -r doc
	fi
}
