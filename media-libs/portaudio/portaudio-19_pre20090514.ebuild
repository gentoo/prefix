# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/portaudio/portaudio-19_pre20090514.ebuild,v 1.1 2009/05/14 17:05:16 aballier Exp $

EAPI=2

inherit libtool

MY_P=pa_stable_v${PV/pre}

DESCRIPTION="An open-source cross platform audio API."
HOMEPAGE="http://www.portaudio.com"
SRC_URI="mirror://gentoo/${MY_P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~ppc-macos"
IUSE="alsa +cxx debug jack oss"

RDEPEND="alsa? ( media-libs/alsa-lib )
	jack? ( >=media-sound/jack-audio-connection-kit-0.109.2-r1 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S=${WORKDIR}/${PN}

src_prepare() {
	elibtoolize
}

src_configure() {
	econf $(use_enable cxx) $(use_with jack) $(use_with alsa) \
		$(use_with oss) $(use_with debug debug-output)
}

src_compile() {
	emake lib/libportaudio.la || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc README.txt
	dohtml index.html
}
