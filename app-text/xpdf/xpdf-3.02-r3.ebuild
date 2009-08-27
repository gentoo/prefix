# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/xpdf/xpdf-3.02-r3.ebuild,v 1.3 2009/08/24 15:20:23 loki_val Exp $

EAPI=2

inherit fdo-mime gnome2 eutils flag-o-matic

DESCRIPTION="An X Viewer for PDF Files"
HOMEPAGE="http://www.foolabs.com/xpdf/"
SRC_URI="http://gentooexperimental.org/~genstef/dist/${P}-poppler-20071121.tar.bz2
	mirror://gentoo/xpdf-3.02-patchset-01.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="nodrm"

RDEPEND="
	>=virtual/poppler-0.11.3
	x11-libs/openmotif
	x11-libs/libX11
	x11-libs/libXpm
	"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S=${WORKDIR}/${P}-poppler

PATCHDIR="${WORKDIR}/${PV}"

pkg_setup() {
	append-flags '-DSYSTEM_XPDFRC="\"${EPREFIX}/etc/xpdfrc\""'
	# We know it's there, probably won't get rid of it, so let's make
	# the build output readable by removing it.
	einfo "Suppressing warning overload with -Wno-write-strings"
	append-cxxflags -Wno-write-strings
}

src_prepare() {
	export EPATCH_SUFFIX=patch
	export EPATCH_SOURCE="${PATCHDIR}"
	epatch
	use nodrm && epatch "${PATCHDIR}/xpdf-3.02-poppler-nodrm.patch"
	epatch "${FILESDIR}"/${P}-darwin.patch
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
