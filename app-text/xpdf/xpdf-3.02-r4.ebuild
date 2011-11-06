# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/xpdf/xpdf-3.02-r4.ebuild,v 1.12 2011/10/18 21:56:02 dilfridge Exp $

EAPI=4

inherit fdo-mime gnome2 eutils flag-o-matic toolchain-funcs

DESCRIPTION="An X Viewer for PDF Files"
HOMEPAGE="http://www.foolabs.com/xpdf/"
SRC_URI="http://gentooexperimental.org/~genstef/dist/${P}-poppler-20071121.tar.bz2
	http://dev.gentoo.org/~scarabeus/xpdf-3.02-patchset-03.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="nodrm"

RDEPEND="
	>=app-text/poppler-0.18.0[xpdf-headers]
	>=x11-libs/openmotif-2.3:0
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
	has_version '>=app-text/poppler-0.16' && epatch	"${FILESDIR}/${P}-poppler-0.16.patch"
	mv parseargs.c parseargs.cc
	epatch "${FILESDIR}"/${P}-darwin.patch
	epatch "${FILESDIR}"/${P}-endian-check-runtime.patch
}

src_configure() {
	:
}

src_compile() {
	tc-export CXX
	emake
}

src_install() {
	dobin xpdf
	doman xpdf.1
	insinto /etc
	doins "${PATCHDIR}"/xpdfrc
	dodoc README ANNOUNCE CHANGES
	doicon "${PATCHDIR}"/xpdf.png
	insinto /usr/share/applications
	doins "${PATCHDIR}"/xpdf.desktop
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
