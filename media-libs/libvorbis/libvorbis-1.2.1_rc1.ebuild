# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libvorbis/libvorbis-1.2.1_rc1.ebuild,v 1.10 2008/06/14 14:30:39 rich0 Exp $

EAPI="prefix"

inherit autotools flag-o-matic eutils toolchain-funcs

MY_P=${P/_/}
DESCRIPTION="the Ogg Vorbis sound file format library"
HOMEPAGE="http://xiph.org/vorbis"
SRC_URI="http://people.xiph.org/~giles/2008/${MY_P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="doc"

RDEPEND=">=media-libs/libogg-1"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"
S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	eautoreconf # need new libtool for interix

	epunt_cxx #74493

	# Insane.
	sed -i -e "s:-O20::g" -e "s:-mfused-madd::g" configure
	sed -i -e "s:-mcpu=750::g" configure
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
