# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/pango/pango-1.16.2.ebuild,v 1.1 2007/04/17 03:55:41 compnerd Exp $

EAPI="prefix"

inherit eutils gnome2 multilib

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
	>=dev-libs/glib-2.12
	>=media-libs/fontconfig-1.0.1
	>=media-libs/freetype-2
	>=x11-libs/cairo-1.2.6"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9
	X? ( x11-proto/xproto )
	doc? (
			>=dev-util/gtk-doc-1
			~app-text/docbook-xml-dtd-4.1.2
		 )"

DOCS="AUTHORS ChangeLog* NEWS README TODO*"

function multilib_enabled() {
	has_multilib_profile || ( use x86 && [ "$(get_libdir)" == "lib32" ] )
}

src_unpack() {
	gnome2_src_unpack

	# make config file location host specific so that a 32bit and 64bit pango
	# wont fight with each other on a multilib system.  Fix building for
	# emul-linux-x86-gtklibs
	if multilib_enabled ; then
		epatch ${FILESDIR}/${PN}-1.2.5-lib64.patch
	fi

	epunt_cxx
}

src_compile() {
	local myconf="$(use_with X x)"
	if use X ; then
		myconf="${myconf} \
			--x-includes='${EPREFIX}'/usr/include \
			--x-libraries='${EPREFIX}'/usr/lib"
	fi
	econf ${myconf} || die "econf failed"
	emake || "emake failed"
}

src_install() {
	gnome2_src_install
	rm ${ED}/etc/pango/pango.modules
}

pkg_postinst() {
	if [[ "${ROOT}" == "/" ]] ; then
		einfo "Generating modules listing..."

		local PANGO_CONFDIR=

		if multilib_enabled ; then
			PANGO_CONFDIR="${EPREFIX}/etc/pango/${CHOST}"
		else
			PANGO_CONFDIR="${EPREFIX}/etc/pango"
		fi

		mkdir -p ${PANGO_CONFDIR}

		pango-querymodules > ${PANGO_CONFDIR}/pango.modules
	fi
}
