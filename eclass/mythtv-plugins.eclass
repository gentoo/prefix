# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mythtv-plugins.eclass,v 1.19 2006/10/14 20:27:21 swegener Exp $
#
# Author: Doug Goldstein <cardoe@gentoo.org>
#
# Installs MythTV plugins along with patches from the release-${PV}-fixes branch
#
inherit mythtv multilib qt3 versionator

# Extra configure options to pass to econf
MTVCONF=${MTVCONF:=""}

SLOT="0"
IUSE="${IUSE} debug mmx"

RDEPEND="${RDEPEND}
		=media-tv/mythtv-${MY_PV}*"
DEPEND="${DEPEND}
		=media-tv/mythtv-${MY_PV}*
		>=sys-apps/sed-4"

S="${WORKDIR}/mythplugins-${MY_PV}"

mythtv-plugins_pkg_setup() {
	# List of available plugins (needs to include ALL of them in the tarball)
	MYTHPLUGINS="mythbrowser mythcontrols mythdvd mythflix mythgallery"
	MYTHPLUGINS="${MYTHPLUGINS} mythgame mythmusic mythnews mythphone"
	MYTHPLUGINS="${MYTHPLUGINS} mythvideo mythweather mythweb"

	if version_is_at_least "0.20" ; then
		MYTHPLUGINS="${MYTHPLUGINS} mytharchive"
	fi
}

mythtv-plugins_src_unpack() {
	unpack ${A}
	cd "${S}"

	mythtv-fixes_patch

	sed -e 's!PREFIX = /usr/local!PREFIX = /usr!' \
	-i 'settings.pro' || die "fixing PREFIX to /usr failed"

	sed -e "s!QMAKE_CXXFLAGS_RELEASE = -O3 -march=pentiumpro -fomit-frame-pointer!QMAKE_CXXFLAGS_RELEASE = ${CXXFLAGS}!" \
	-i 'settings.pro' || die "Fixing QMake's CXXFLAGS failed"

	sed -e "s!QMAKE_CFLAGS_RELEASE = \$\${QMAKE_CXXFLAGS_RELEASE}!QMAKE_CFLAGS_RELEASE = ${CFLAGS}!" \
	-i 'settings.pro' || die "Fixing Qmake's CFLAGS failed"

	find "${S}" -name '*.pro' -exec sed -i \
		-e "s:\$\${PREFIX}/lib/:\$\${PREFIX}/$(get_libdir)/:g" \
		-e "s:\$\${PREFIX}/lib$:\$\${PREFIX}/$(get_libdir):g" \
	{} \;
}

mythtv-plugins_src_compile() {
	cd "${S}"

	if use debug; then
		sed -e 's!CONFIG += release!CONFIG += debug!' \
		-i 'settings.pro' || die "switching to debug build failed"
	fi

#	if ( use x86 && ! use mmx ) || ! use amd64 ; then
	if ( ! use mmx ); then
		sed -e 's!DEFINES += HAVE_MMX!DEFINES -= HAVE_MMX!' \
		-i 'settings.pro' || die "disabling MMX failed"
	fi

	local myconf=""

	if hasq ${PN} ${MYTHPLUGINS} ; then
		for x in ${MYTHPLUGINS} ; do
			if [[ ${PN} == ${x} ]] ; then
				myconf="${myconf} --enable-${x}"
			else
				myconf="${myconf} --disable-${x}"
			fi
		done
	else
		die "Package ${PN} is unsupported"
	fi

	econf ${myconf} ${MTVCONF}

	${QTDIR}/bin/qmake QMAKE="${QTDIR}/bin/qmake" -o "Makefile" mythplugins.pro || die "qmake failed to run"
	emake || die "make failed to compile"
}

mythtv-plugins_src_install() {
	if hasq ${PN} ${MYTHPLUGINS} ; then
		cd "${S}"/${PN}
	else
		die "Package ${PN} is unsupported"
	fi

	einstall INSTALL_ROOT="${D}"
	for doc in AUTHORS COPYING FAQ UPGRADING ChangeLog README; do
		test -e "${doc}" && dodoc ${doc}
	done
}

EXPORT_FUNCTIONS pkg_setup src_unpack src_compile src_install
