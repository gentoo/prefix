# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/gst-plugins-base/gst-plugins-base-0.10.12.ebuild,v 1.2 2007/03/20 11:01:02 zaheerm Exp $

EAPI="prefix"

# order is important, gnome2 after gst-plugins
inherit gst-plugins-base gst-plugins10 gnome2 eutils flag-o-matic libtool

DESCRIPTION="Basepack of plugins for gstreamer"
HOMEPAGE="http://gstreamer.net/"
SRC_URI="http://gstreamer.freedesktop.org/src/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~ia64 ~x86"
IUSE="alsa esd oss X xv"

RDEPEND=">=dev-libs/glib-2.8
	 >=media-libs/gstreamer-0.10.12
	 >=dev-libs/liboil-0.3.8"
DEPEND="${RDEPEND}
	>=sys-devel/gettext-0.11.5
	>=dev-util/pkgconfig-0.9"
PDEPEND="oss? ( >=media-plugins/gst-plugins-oss-0.10 )
	alsa? ( >=media-plugins/gst-plugins-alsa-0.10 )
	esd? ( >=media-plugins/gst-plugins-esd-0.10 )
	X? ( >=media-plugins/gst-plugins-x-0.10 )
	xv? ( >=media-plugins/gst-plugins-xvideo-0.10 )"

DOCS="AUTHORS INSTALL README RELEASE TODO"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${PN}.audioresample.patch
}

src_compile() {
	elibtoolize

	# gst doesnt handle optimisations well
	strip-flags
	replace-flags "-O3" "-O2"
	filter-flags "-fprefetch-loop-arrays" # see bug 22249
	if use alpha || use amd64 || use ia64 || use hppa; then
		append-flags -fPIC
	fi

	gst-plugins-base_src_configure

	emake || die
}

# override eclass
src_install() {
	gnome2_src_install
}
