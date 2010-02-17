# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/xpdf/xpdf-3.02-r4.ebuild,v 1.7 2010/02/11 17:03:17 jer Exp $

EAPI=2

inherit fdo-mime gnome2 eutils flag-o-matic

DESCRIPTION="An X Viewer for PDF Files"
HOMEPAGE="http://www.foolabs.com/xpdf/"
SRC_URI="http://gentooexperimental.org/~genstef/dist/${P}-poppler-20071121.tar.bz2
	mirror://gentoo/xpdf-3.02-patchset-02.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="nodrm"

RDEPEND="
	>=app-text/poppler-0.12.3-r3[xpdf-headers]
	x11-libs/openmotif
	x11-libs/libX11
	x11-libs/libXpm
	"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	virtual/libiconv"

S=${WORKDIR}/${P}-poppler

PATCHDIR="${WORKDIR}/${PV}"

pkg_setup() {
	append-flags '-DSYSTEM_XPDFRC="\"${EPREFIX}/etc/xpdfrc\""'
	# We know it's there, probably won't get rid of it, so let's make
	# the build output readable by removing it.
	einfo "Suppressing warning overload with -Wno-write-strings"
	append-cxxflags -Wno-write-strings
	# Makefile doesn't use LIBS
	[[ ${CHOST} != *-linux-gnu ]] && append-ldflags -liconv
}

src_prepare() {
	export EPATCH_SUFFIX=patch
	export EPATCH_SOURCE="${PATCHDIR}"
	epatch
	use nodrm && epatch "${PATCHDIR}/xpdf-3.02-poppler-nodrm.patch"
	epatch "${FILESDIR}"/${P}-darwin.patch
	epatch "${FILESDIR}"/${P}-endian-check-runtime.patch
}

src_configure() {
	:
}

src_compile() {
	emake || die
}

src_install() {
	dobin xpdf || die
	doman xpdf.1 || die
	insinto /etc || die
	doins "${PATCHDIR}"/xpdfrc || die
	dodoc README ANNOUNCE CHANGES || die
	doicon "${PATCHDIR}"/xpdf.png || die
	insinto /usr/share/applications || die
	doins "${PATCHDIR}"/xpdf.desktop || die
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
}
