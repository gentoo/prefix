# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/gst-plugins-bad/gst-plugins-bad-0.10.14.ebuild,v 1.4 2009/11/10 16:09:34 tester Exp $

inherit gst-plugins-bad gnome2 eutils flag-o-matic libtool

DESCRIPTION="Less plugins for GStreamer"
HOMEPAGE="http://gstreamer.freedesktop.org/"
SRC_URI="http://gstreamer.freedesktop.org/src/${PN}/${P}.tar.bz2
	http://dev.gentoo.org/~leio/distfiles/${P}-kate-configure-fix.patch.bz2"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=media-libs/gst-plugins-base-0.10.24
	>=media-libs/gstreamer-0.10.24
	>=dev-libs/glib-2.16
	!<media-plugins/gst-plugins-farsight-0.12.11"

DEPEND="${RDEPEND}"

src_unpack() {
	gnome2_src_unpack

	# Fix compilation with --disable-kate. Only applicable
	# to 0.10.14, on bump remove src_unpack and patch from SRC_URI
	epatch "${WORKDIR}/${P}-kate-configure-fix.patch"
}

src_compile() {
	strip-flags
	replace-flags "-O3" "-O2"
	filter-flags "-fprefetch-loop-arrays" # (Bug #22249)

	gst-plugins-bad_src_configure

	emake || die "emake failed."
}

src_install() {
	gnome2_src_install
}

DOCS="AUTHORS ChangeLog NEWS README RELEASE"

pkg_postinst() {
	gnome2_pkg_postinst
}

pkg_postrm() {
	gnome2_pkg_postrm
}
