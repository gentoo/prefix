# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/openexr/openexr-1.6.1.ebuild,v 1.14 2010/03/10 02:59:43 sping Exp $

inherit libtool eutils

DESCRIPTION="ILM's OpenEXR high dynamic-range image file format libraries"
HOMEPAGE="http://openexr.com/"
SRC_URI="http://download.savannah.gnu.org/releases/openexr/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="doc examples"

RDEPEND="media-libs/ilmbase"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Replace the temporary directory used for tests.
	sed -i -e 's:"/var/tmp/":"'${T}'":' "IlmImfTest/tmpDir.h"

	epatch "${FILESDIR}/${P}-gcc-4.3.patch"

	# gcc-apple-4.2.1 dies on this
	sed -i -e "s/-Wno-long-double//g" "${S}/configure" || die

	# Sane versioning on FreeBSD - please don't remove elibtoolize
	elibtoolize
}

src_compile() {
	econf $(use_enable examples imfexamples)
	emake || die "emake failed"
}

src_install () {
	emake DESTDIR="${D}" examplesdir="${EPREFIX}/usr/share/doc/${PF}/examples" install || \
		die "install failed"
	dodoc AUTHORS ChangeLog NEWS README

	if use doc ; then
		insinto "/usr/share/doc/${PF}"
		doins doc/*.pdf
	fi
	rm -frv "${ED}usr/share/doc/OpenEXR"*

	if use examples ; then
		dobin "IlmImfExamples/imfexamples"
	else
		rm -fr "${ED}usr/share/doc/${PF}/examples"
	fi
}

pkg_postinst() {
	elog "OpenEXR was divided into IlmBase, OpenEXR, and OpenEXR_Viewers."
	elog "Viewers are available in OpenEXR_Viewers package."
	elog "If you want them, run: emerge media-gfx/openexr_viewers"
}
