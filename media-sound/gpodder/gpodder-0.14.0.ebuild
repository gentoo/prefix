# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/gpodder/gpodder-0.14.0.ebuild,v 1.1 2009/01/13 12:24:00 hanno Exp $

inherit distutils

DESCRIPTION="gPodder is a Podcast receiver/catcher written in Python, using GTK."
HOMEPAGE="http://gpodder.berlios.de/"
SRC_URI="mirror://berlios/${PN}/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE="ipod libnotify mad"
RESTRICT="test"

RDEPEND="dev-python/feedparser
	dev-python/pygtk
	sys-devel/gettext
	libnotify? ( dev-python/notify-python )
	>=dev-python/pysqlite-2.4
	dev-python/eyeD3
	ipod? ( media-libs/libgpod )
	mad? ( dev-python/pymad )"
DEPEND="${RDEPEND}
	dev-util/intltool
	media-gfx/imagemagick
	sys-apps/help2man"

pkg_setup() {
	if use ipod && ! built_with_use media-libs/libgpod python ; then
		eerror "media-libs/libgpod has to be compiled with USE=python"
		die "Needed USE-flag for libgpod not found."
	fi
	if ! built_with_use 'media-gfx/imagemagick' 'png'; then
		eerror "You must build imagemagick with png support"
		die "media-gfx/imagemagick built without png"
	fi
}

src_compile() {
	emake generators || die
	emake messages || die
	distutils_src_compile || die
}
