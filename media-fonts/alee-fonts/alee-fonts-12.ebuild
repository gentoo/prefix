# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-fonts/alee-fonts/alee-fonts-12.ebuild,v 1.6 2009/06/01 12:19:56 maekke Exp $

inherit font

DESCRIPTION="A Lee's Hangul truetype fonts"
HOMEPAGE="http://packages.debian.org/unstable/x11/ttf-alee"
SRC_URI="mirror://debian/pool/main/t/ttf-alee/ttf-alee_${PV}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

FONT_SUFFIX="ttf"
FONT_S="${WORKDIR}/ttf-alee-${PV}"

S=${FONT_S}
