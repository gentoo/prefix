# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/portaudio/portaudio-19_pre061121.ebuild,v 1.2 2007/04/12 13:20:01 genstef Exp $

EAPI="prefix"

MY_PN=pa_stable_v
MY_PV=${PV/pre/}
MY_P=${MY_PN}${MY_PV}

DESCRIPTION="An open-source cross platform audio API."
HOMEPAGE="http://www.portaudio.com"
SRC_URI="http://www.portaudio.com/archives/${MY_P}.tar.gz"

LICENSE="as-is"
SLOT="18"
KEYWORDS="~ppc-macos"
IUSE="alsa debug jack oss"

DEPEND="alsa? ( media-libs/alsa-lib )
	jack? ( media-sound/jack-audio-connection-kit )"
RDEPEND="${DEPEND}"


S="${WORKDIR}/${PN}"


src_compile() {
	econf $(use_with alsa)\
		$(use_with jack)\
		$(use_with oss)\
		$(use_with debug debug-output)\
		--enable-cxx\
		|| die "econf failed"

	emake || die "emake failed"

}

src_install() {
	emake DESTDIR="${D}" install || die "emake install faied"
	dodoc V19-devel-readme.txt
	dohtml index.html
}
