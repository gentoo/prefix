# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit flag-o-matic libtool

DESCRIPTION="The Theora Video Compression Codec"
HOMEPAGE="http://www.theora.org/"
SRC_URI="http://downloads.xiph.org/releases/theora/${P/_}.tar.bz2"

LICENSE="xiph"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE="encode doc examples"

RDEPEND=">=media-libs/libogg-1.1.0
	encode? ( >=media-libs/libvorbis-1.0.1 )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

S=${WORKDIR}/${P/_}

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e 's:SUBDIRS = .*:SUBDIRS = lib include doc:' Makefile.in

	elibtoolize

	if use examples; then
		# This creates a clean copy of examples sources
		cp -R "${S}/examples" "${WORKDIR}"
		rm -f "${WORKDIR}/examples/Makefile"*
	fi
}

src_compile() {
	# bug #75403, -O3 needs to be filtered to -O2
	replace-flags -O3 -O2

	use doc || export ac_cv_prog_HAVE_DOXYGEN="false"

	econf \
		$(use_enable encode) \
		--enable-shared \
		--disable-dependency-tracking \
		|| die "configure failed"
	emake || die "make failed"
}

src_install() {
	emake -j1 \
		DESTDIR="${D}" \
		docdir="${EPREFIX}/usr/share/doc/${PF}" \
		install || die "make install failed"

	if use examples; then
		insinto "/usr/share/doc/${PF}/examples"
		doins "${WORKDIR}/examples/"*
	fi

	dodoc README
}
