# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/gst-plugins-base/gst-plugins-base-0.10.17.ebuild,v 1.3 2008/04/14 19:34:14 fmccor Exp $

EAPI="prefix"

# order is important, gnome2 after gst-plugins
inherit gst-plugins-base gst-plugins10 gnome2 libtool flag-o-matic eutils

DESCRIPTION="Basepack of plugins for gstreamer"
HOMEPAGE="http://gstreamer.sourceforge.net"
SRC_URI="http://gstreamer.freedesktop.org/src/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE="debug nls"

RDEPEND=">=dev-libs/glib-2.8
	>=media-libs/gstreamer-0.10.17
	>=dev-libs/liboil-0.3.8
	debug? ( dev-util/valgrind )"
DEPEND="${RDEPEND}
	nls? ( >=sys-devel/gettext-0.11.5 )
	>=dev-util/pkgconfig-0.9"

DOCS="AUTHORS README RELEASE"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-interix.patch

	# Needed for sane .so versioning on Gentoo/FreeBSD
	elibtoolize
}

src_compile() {
	# gst doesnt handle optimisations well, last
	# tested with 0.10.15
	strip-flags
	replace-flags "-O3" "-O2"

	[[ ${CHOST} == *-interix* ]] && append-flags -D_ALL_SOURCE

	gst-plugins-base_src_configure \
		$(use_enable nls) \
		$(use_enable debug valgrind) \
		$(use_enable debug)
	emake || die "emake failed."
}

src_install() {
	gnome2_src_install
}
