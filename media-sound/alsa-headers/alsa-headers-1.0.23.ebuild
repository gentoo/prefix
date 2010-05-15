# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/alsa-headers/alsa-headers-1.0.23.ebuild,v 1.1 2010/04/16 22:12:06 chainsaw Exp $

inherit eutils

MY_PN=${PN/headers/driver}
MY_P="${MY_PN}-${PV/_rc/rc}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="Header files for Advanced Linux Sound Architecture kernel modules"
HOMEPAGE="http://www.alsa-project.org/"
SRC_URI="mirror://alsaproject/driver/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=""
RDEPEND=""

RESTRICT="binchecks strip"

# Remove the sound symlink workaround...
pkg_setup() {
	if [[ -L "${EROOT}/usr/include/sound" ]]; then
		rm	"${EROOT}/usr/include/sound"
	fi
}

src_unpack() {
	unpack ${A}

	cd "${S}"
	epatch "${FILESDIR}/${PN}-1.0.6a-user.patch"
}

src_compile() { :; }

src_install() {
	cd "${S}/alsa-kernel/include"
	insinto /usr/include/sound
	doins *.h || die "include failed"
}
