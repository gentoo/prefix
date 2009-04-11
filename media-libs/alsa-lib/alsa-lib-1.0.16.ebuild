# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/alsa-lib/alsa-lib-1.0.16.ebuild,v 1.10 2009/03/31 09:31:16 armin76 Exp $

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="1.9"

inherit eutils autotools libtool

MY_P="${P/_rc/rc}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="Advanced Linux Sound Architecture Library"
HOMEPAGE="http://www.alsa-project.org/"
SRC_URI="mirror://alsaproject/lib/${MY_P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="doc debug alisp midi"

RDEPEND=""
DEPEND=">=media-sound/alsa-headers-${PV}
	doc? ( >=app-doc/doxygen-1.2.6 )"

IUSE_PCM_PLUGIN="copy linear route mulaw alaw adpcm rate plug multi shm file null empty share meter hooks lfloat ladspa dmix dshare dsnoop asym iec958
softvol extplug ioplug"

for plugin in ${IUSE_PCM_PLUGIN}; do
	IUSE="${IUSE} alsa_pcm_plugins_${plugin}"
done

pkg_setup() {
	if [ -z "${ALSA_PCM_PLUGINS}" ] ; then
		ewarn "You haven't selected _any_ PCM plugins. Either you set it to something like the default"
		ewarn "(which is being set in the profile UNLESS you unset them) or alsa based applications"
		ewarn "are going to *misbehave* !"
		epause 5
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	elibtoolize
	epunt_cxx
}

src_compile() {
	local myconf
	use elibc_uclibc && myconf="--without-versioned"

	# needed to avoid gcc looping internaly
	use hppa && export CFLAGS="-O1 -pipe"

	econf \
		--enable-static \
		--enable-shared \
		--disable-resmgr \
		$(use_with debug) \
		$(use_enable alisp) \
		$(use_enable midi instr) \
		$(use_enable midi seq) $(use_enable midi aload) \
		--with-pcm-plugins="${ALSA_PCM_PLUGINS}" \
		--disable-dependency-tracking \
		${myconf} \
		|| die "configure failed"

	emake || die "make failed"

	if use doc; then
		emake doc || die "failed to generate docs"
		fgrep -Zrl "${S}" "${S}/doc/doxygen/html" | \
			xargs -0 sed -i -e "s:${S}::"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	dodoc ChangeLog TODO
	use doc && dohtml -r doc/doxygen/html/*
}

pkg_postinst() {
	ewarn "Starting from alsa 1.0.11_rc3 the configuration for dmix is changed."
	ewarn "Leaving around old asound.conf or ~/.asoundrc might make all apps"
	ewarn "using ALSA output crash."
	ewarn "Note that dmix output is enabled by default on the 'default' device"
	ewarn "since ALSA 1.0.9."
	elog ""
	elog "Please try in-kernel ALSA drivers instead of the alsa-drivers ebuild."
	elog "If alsa-drivers works for you where a recent kernel does not, we want "
	elog "to know about this. Our e-mail address is alsa-bugs@gentoo.org"
	elog "However, if you notice no sound output or instability, please try to "
	elog "upgrade your kernel to a newer version first."
}
