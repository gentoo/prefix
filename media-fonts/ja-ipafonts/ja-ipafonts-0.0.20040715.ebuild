# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-fonts/ja-ipafonts/ja-ipafonts-0.0.20040715.ebuild,v 1.11 2008/01/15 17:58:36 grobian Exp $

inherit font

DESCRIPTION="Japanese TrueType fonts developed by IPA (Information-technology Promotion Agency, Japan)"
HOMEPAGE="http://www.grass-japan.org/FOSS4G/readme-grass-i18n-ipafonts.eucjp.htm"
SRC_URI="http://www.grass-japan.org/FOSS4G/ipafonts/grass5.0.3_i686-pc-linux-i18n-ipafull-gnu_bin.tar.gz"
LICENSE="grass-ipafonts"

SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

S="${WORKDIR}"
FONT_SUFFIX="ttf"
FONT_S="${S}/fonts"

DOCS="readme-grass-i18n-ipafonts.eucjp license-ipafonts.eucjp"

# Only installs fonts
RESTRICT="mirror strip binchecks"
