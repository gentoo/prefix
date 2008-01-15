# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-fonts/alee-fonts/alee-fonts-11.4.ebuild,v 1.2 2007/08/25 11:32:06 vapier Exp $

EAPI="prefix"

inherit font

DESCRIPTION="A Lee's Hangul truetype fonts"
HOMEPAGE="http://packages.debian.org/unstable/x11/ttf-alee"
SRC_URI="mirror://debian/pool/main/t/ttf-alee/ttf-alee_${PV}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~x86-fbsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

FONT_SUFFIX="ttf"
FONT_S="${WORKDIR}/ttf-alee-${PV}"

S=${FONT_S}

# Only installs fonts
RESTRICT="strip binchecks"
