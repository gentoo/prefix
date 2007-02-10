# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/pango/pango-1.14.10.ebuild,v 1.2 2007/02/04 03:12:33 leio Exp $

EAPI="prefix"

inherit eutils gnome2

DESCRIPTION="Text rendering and layout library"
HOMEPAGE="http://www.pango.org/"

LICENSE="LGPL-2 FTL"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE="doc X"

RDEPEND="X? (
		x11-libs/libXrender
		x11-libs/libX11
		x11-libs/libXft
	)
	>=dev-libs/glib-2.10.0
	>=media-libs/fontconfig-1.0.1
	>=media-libs/freetype-2
	>=x11-libs/cairo-1.2.2"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9
	X? ( x11-proto/xproto )
	doc? (
		>=dev-util/gtk-doc-1
		~app-text/docbook-xml-dtd-4.1.2
	)"

DOCS="AUTHORS ChangeLog* NEWS README"

src_unpack() {
	gnome2_src_unpack

	# Some enhancements from Redhat
	# These NEED to go upstream.
	epatch ${FILESDIR}/pango-1.11.3-xfonts.patch
	epatch ${FILESDIR}/${PN}-1.10.2-slighthint.patch

	# make config file location host specific so that a 32bit and 64bit pango
	# wont fight with each other on a multilib system
	use amd64 && epatch ${FILESDIR}/pango-1.2.5-lib64.patch

	# and this line is just here to make building emul-linux-x86-gtklibs a bit
	# easier, so even this should be amd64 specific.
	use x86 && [ "${CONF_LIBDIR}" == "lib32" ] && epatch ${FILESDIR}/pango-1.2.5-lib64.patch

	epunt_cxx
}

src_compile() {
	econf $(use_with X x) || die "econf failed"
	emake || "emake failed"
}

pkg_postinst() {
	einfo "Generating modules listing..."

	use amd64 && PANGO_CONFDIR="${EPREFIX}/etc/pango/${CHOST}"
	use x86 && [ "${CONF_LIBDIR}" == "lib32" ] && PANGO_CONFDIR="${EPREFIX}/etc/pango/${CHOST}"

	PANGO_CONFDIR=${PANGO_CONFDIR:="${EPREFIX}/etc/pango"}
	mkdir -p ${PANGO_CONFDIR}

	pango-querymodules > ${PANGO_CONFDIR}/pango.modules
}
