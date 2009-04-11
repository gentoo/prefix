# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/thunar-thumbnailers/thunar-thumbnailers-0.4.0.ebuild,v 1.1 2008/08/21 19:26:55 angelos Exp $

inherit xfce44

xfce44

DESCRIPTION="Thunar thumbnailers plugin"
HOMEPAGE="http://goodies.xfce.org/projects/thunar-plugins/thunar-thumbnailers"
SRC_URI="http://goodies.xfce.org/releases/${PN}/${P}${COMPRESS}"

KEYWORDS="~amd64-linux ~x86-linux"
IUSE="ffmpeg grace latex raw"

RDEPEND="xfce-base/thunar
	media-gfx/imagemagick
	app-arch/unzip
	raw? ( media-gfx/raw-thumbnailer media-gfx/dcraw )
	grace? ( sci-visualization/grace )
	latex? ( virtual/latex-base )
	ffmpeg? ( media-video/ffmpegthumbnailer )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

pkg_setup() {
	XFCE_CONFIG+=" $(use_enable latex tex) $(use_enable raw) $(use_enable grace)
		$(use_enable ffmpeg) --disable-update-mime-database"
}

pkg_postinst() {
	xfce44_pkg_postinst
	elog "Existing users need to run /usr/libexec/thunar-vfs-update-thumbnailers-cache-1."
}

DOCS="AUTHORS ChangeLog NEWS README"
