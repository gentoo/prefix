# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/exiv2/exiv2-0.18.ebuild,v 1.4 2009/05/19 20:31:14 ranger Exp $

inherit eutils

DESCRIPTION="EXIF and IPTC metadata C++ library and command line utility"
HOMEPAGE="http://www.exiv2.org/"
SRC_URI="http://www.exiv2.org/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="doc nls zlib xmp examples unicode"
IUSE_LINGUAS="de es fi fr pl ru sk"
IUSE="${IUSE} $(printf 'linguas_%s ' ${IUSE_LINGUAS})"

RDEPEND="zlib? ( sys-libs/zlib )
	xmp? ( dev-libs/expat )
	nls? ( virtual/libintl )
	virtual/libiconv"
DEPEND="${RDEPEND}
	doc? (
		dev-lang/python
		app-doc/doxygen
		dev-libs/libxslt
		dev-util/pkgconfig
		media-gfx/graphviz
	)
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	if use unicode; then
		for i in doc/cmd.txt; do
			echo ">>> Converting "${i}" to UTF-8"
			iconv -f LATIN1 -t UTF-8 "${i}" > "${i}~" && mv -f "${i}~" "${i}" || rm -f "${i}~"
		done
	fi

	if use doc; then
		echo ">>> Updating doxygen config"
		doxygen 2>&1 >/dev/null -u config/Doxyfile
	fi
}

src_compile() {
	local myconf="$(use_enable nls) $(use_enable xmp)"
	use zlib || myconf="${myconf} --without-zlib"  # plain 'use_with' fails
	econf ${myconf} || die "econf failed"
	# Needed for Solaris because /bin/sh is not a bash, bug #245647
	if [[ ${CHOST} == *-solaris* ]]; then
		sed -i -e "s:/bin/sh:${EPREFIX}/bin/sh:" src/Makefile || die "sed failed"
	fi
	emake || die "emake failed"
	if use doc; then
		emake doc || die "emake doc failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc README doc/{ChangeLog,cmd.txt}
	use xmp && dodoc doc/{COPYING-XMPSDK,README-XMP,cmdxmp.txt}
	use doc && dohtml -r doc/html/.
	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins samples/*.cpp
	fi
}

pkg_postinst() {
	ewarn
	ewarn "PLEASE PLEASE take note of this:"
	ewarn "Please make *sure* to run revdep-rebuild now"
	ewarn "Certain things on your system may have linked against a"
	ewarn "different version of exiv2 -- those things need to be"
	ewarn "recompiled. Sorry for the inconvenience!"
	ewarn
}
