# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/gst-plugins-base/gst-plugins-base-0.10.21.ebuild,v 1.3 2008/12/09 12:02:35 ssuominen Exp $

# order is important, gnome2 after gst-plugins
inherit gst-plugins-base gst-plugins10 gnome2 flag-o-matic autotools eutils
# libtool

DESCRIPTION="Basepack of plugins for gstreamer"
HOMEPAGE="http://gstreamer.sourceforge.net"
SRC_URI="http://gstreamer.freedesktop.org/src/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="debug nls"

RDEPEND=">=dev-libs/glib-2.8
	>=media-libs/gstreamer-0.10.21
	>=dev-libs/liboil-0.3.14"
DEPEND="${RDEPEND}
	nls? ( >=sys-devel/gettext-0.11.5 )
	dev-util/pkgconfig"

DOCS="AUTHORS README RELEASE"

src_unpack() {
	unpack ${A}
	cd "${S}"

# time these get fixed properly and sent upstream!
#	epatch "${FILESDIR}"/${PN}-0.10.19-interix.patch
#	[[ ${CHOST} == *-interix[35]* ]] && epatch "${FILESDIR}"/${PN}-0.10.19-interix5.patch
#	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${P}-interix3.patch
#	[[ ${CHOST} == *-interix5* ]] && epatch "${FILESDIR}"/${P}-interix5.patch

	# Needed for sane .so versioning on Gentoo/FreeBSD
	# elibtoolize
	epatch "${FILESDIR}"/${P}-gtkdoc.patch
	AT_M4DIR="common/m4" eautoreconf
}

src_compile() {
	# gst doesnt handle opts well, last tested with 0.10.15
	strip-flags
	replace-flags "-O3" "-O2"

	gst-plugins-base_src_configure \
		$(use_enable nls) \
		$(use_enable debug)
	emake || die "emake failed."
}

src_install() {
	gnome2_src_install
}
