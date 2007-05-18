# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-esd/eselect-esd-20060719.ebuild,v 1.21 2007/05/10 08:00:17 grobian Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Manages configuration of ESounD implementation or PulseAudio wrapper"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/esd.eselect-${PVR}.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""

RDEPEND=">=app-admin/eselect-1.0.2
	!<media-sound/esound-0.2.36-r2"

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}"/esd.eselect-${PVR}-prefix.patch
	eprefixify esd.eselect-${PVR}
}

src_install() {
	insinto /usr/share/eselect/modules
	newins "${WORKDIR}/esd.eselect-${PVR}" esd.eselect || die
}
