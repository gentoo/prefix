# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/gst-plugins-good/gst-plugins-good-0.10.17.ebuild,v 1.6 2010/06/24 16:52:28 jer Exp $

# order is important, gnome2 after gst-plugins
inherit gst-plugins-good gst-plugins10 gnome2 eutils flag-o-matic libtool

DESCRIPTION="Basepack of plugins for gstreamer"
HOMEPAGE="http://gstreamer.net/"
SRC_URI="http://gstreamer.freedesktop.org/src/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-macos ~x86-solaris"
IUSE=""

RDEPEND=">=media-libs/gst-plugins-base-0.10.25
	 >=media-libs/gstreamer-0.10.25
	 >=dev-libs/liboil-0.3.14"
DEPEND="${RDEPEND}
	>=sys-devel/gettext-0.11.5
	dev-util/pkgconfig
	!<media-libs/gst-plugins-bad-0.10.14"

# overrides the eclass
src_unpack() {
	unpack ${A}
	cd "${S}"

	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${PN}-0.10.8-interix3.patch

	# Required for FreeBSD sane .so versioning
	elibtoolize
}

src_compile() {
	# gst doesnt handle optimisations well
	strip-flags
	replace-flags "-O3" "-O2"
	filter-flags "-fprefetch-loop-arrays" # see bug 22249

	gst-plugins-good_src_configure \
		--with-default-audiosink=autoaudiosink \
		--with-default-visualizer=goom

	emake || die "emake failed."
}

# override eclass
src_install() {
	gnome2_src_install
}

DOCS="AUTHORS README RELEASE"

pkg_postinst () {
	gnome2_pkg_postinst

	echo
	elog "The Gstreamer plugins setup has changed quite a bit on Gentoo,"
	elog "applications now should provide the basic plugins needed."
	echo
	elog "The new seperate plugins are all named 'gst-plugins-<plugin>'."
	elog "To get a listing of currently available plugins execute 'emerge -s gst-plugins-'."
	elog "In most cases it shouldn't be needed though to emerge extra plugins."
}

pkg_postrm() {
	gnome2_pkg_postrm
}
