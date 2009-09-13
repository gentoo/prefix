# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/farsight2/farsight2-0.0.15.ebuild,v 1.3 2009/09/11 22:00:25 volkmar Exp $

EAPI="2"

DESCRIPTION="Farsight2 is an audio/video conferencing framework specifically designed for Instant Messengers."
HOMEPAGE="http://farsight.freedesktop.org/"
SRC_URI="http://farsight.freedesktop.org/releases/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="python test msn"
SLOT="0"

COMMONDEPEND=">=media-libs/gstreamer-0.10.23
	>=media-libs/gst-plugins-base-0.10.23
	>=dev-libs/glib-2.16
	>=net-libs/libnice-0.0.9[gstreamer]
	python? (
		|| ( >=dev-python/pygobject-2.16 >=dev-python/pygtk-2.12 )
		>=dev-python/pygobject-2.12
		>=dev-python/gst-python-0.10.10 )"

RDEPEND="${COMMONDEPEND}
	>=media-libs/gst-plugins-good-0.10.11
	>=media-libs/gst-plugins-bad-0.10.13
	|| ( >=media-libs/gst-plugins-good-0.10.16
		<media-libs/gst-plugins-bad-0.10.14 )
	msn? ( >=media-plugins/gst-plugins-mimic-0.10.14 )"

DEPEND="${COMMONDEPEND}
	test? ( media-plugins/gst-plugins-vorbis
		media-plugins/gst-plugins-speex )
	dev-util/pkgconfig"

src_configure() {
	plugins="fsrtpconference,funnel,rtcpfilter,videoanyrate"
	use msn && plugins="${plugins},fsmsnconference"
	econf $(use_enable python) --with-plugins=${plugins}
}

src_install() {
	emake install DESTDIR="${D}" || die "emake install failed"
	dodoc AUTHORS README ChangeLog
}
