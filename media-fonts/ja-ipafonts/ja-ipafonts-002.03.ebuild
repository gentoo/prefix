# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-fonts/ja-ipafonts/ja-ipafonts-002.03.ebuild,v 1.1 2008/09/20 16:14:36 matsuu Exp $

EAPI="prefix"

inherit font

MY_P="IPAfont${PV/.}"
DESCRIPTION="Japanese TrueType fonts developed by IPA (Information-technology Promotion Agency, Japan)"
HOMEPAGE="http://ossipedia.ipa.go.jp/ipafont/"
SRC_URI="http://ossipedia.ipa.go.jp/ipafont/${MY_P}.php/${MY_P}.zip"

LICENSE="IPAfont"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

S="${WORKDIR}/${MY_P}"
FONT_SUFFIX="ttf"
FONT_S="${S}"

DOCS="Readme*.txt"

# Only installs fonts
RESTRICT="mirror strip binchecks"
