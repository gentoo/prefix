# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/povray/povray-3.7.0_beta25-r1.ebuild,v 1.1 2008/05/09 13:06:07 lavajoe Exp $

EAPI="prefix"

inherit eutils autotools flag-o-matic versionator

MY_PV=$(get_version_component_range 1-3)
MY_MINOR_VER=$(get_version_component_range 4)
if [ -n "$MY_MINOR_VER" ]; then
	MY_MINOR_VER=${MY_MINOR_VER/beta/beta.}
	MY_PV="${MY_PV}.${MY_MINOR_VER}b"
fi

DESCRIPTION="The Persistence of Vision Raytracer"
HOMEPAGE="http://www.povray.org/"
SRC_URI="http://www.povray.org/beta/source/${PN}-src-${MY_PV}.tar.bz2"

LICENSE="povlegal-3.6"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="svga tiff X"

DEPEND="media-libs/libpng
	tiff? ( >=media-libs/tiff-3.6.1 )
	media-libs/jpeg
	sys-libs/zlib
	X? ( x11-libs/libXaw )
	svga? ( media-libs/svgalib )
	>=dev-libs/boost-1.33"

S="${WORKDIR}/${PN}-${MY_PV}"

src_compile() {
	# Fixes bug 71255
	if [[ $(get-flag march) == k6-2 ]]; then
		filter-flags -fomit-frame-pointer
	fi

	# The config files are installed correctly (e.g. povray.conf),
	# but the code compiles using incorrect [default] paths
	# (based on /usr/local...), so povray will not find the system
	# config files without the following fix:
	MY_MAIN_VER=$(get_version_component_range 1-2)
	append-flags -DPOVLIBDIR=\\\"${EPREFIX}/usr/share/${PN}\\\"
	append-flags -DPOVCONFDIR=\\\"${EPREFIX}/etc/${PN}\\\"

	# Change some destination directories that cannot be adjusted via configure
	cp configure.ac configure.ac.orig
	sed -i -e 's:${povsysconfdir}/$PACKAGE/$VERSION_BASE:${povsysconfdir}/'${PN}':g' configure.ac
	sed -i -e 's:${povdatadir}/$PACKAGE-$VERSION_BASE:${povdatadir}/'${PN}':g' configure.ac
	sed -i -e 's:${povdatadir}/doc/$PACKAGE-$VERSION_BASE:${povdatadir}/doc/'${PF}':g' configure.ac

	cp Makefile.am Makefile.am.orig
	sed -i -e "s:^povlibdir = .*:povlibdir = @datadir@/${PN}:" Makefile.am
	sed -i -e "s:^povdocdir = .*:povdocdir = @datadir@/doc/${PF}:" Makefile.am
	sed -i -e "s:^povconfdir = .*:povconfdir = @sysconfdir@/${PN}:" Makefile.am

	autoreconf

	econf \
		COMPILED_BY="${USER} <${USER}@`uname -n`>" \
		$(use_with svga) \
		$(use_with tiff) \
		$(use_with X) \
		|| die

	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
}

pkg_preinst() {
	# Copy the old config files if they are in the old location
	# but do not yet exist in the new location.
	# This way, they can be treated by CONFIG_PROTECT as normal.
	for conf_file in $(ls "${ED}/etc/${PN}"); do
		if [ ! -e "${EROOT}etc/${PN}/${conf_file}" ]; then
			for version_dir in $(ls "${EROOT}etc/${PN}" | grep "^[0-9]" | sort -rn); do
				if [ -e "${EROOT}etc/${PN}/${version_dir}/${conf_file}" ]; then
					mv "${EROOT}etc/${PN}/${version_dir}/${conf_file}" "${EROOT}etc/${PN}"
					elog "Note: ${conf_file} moved from ${EROOT}etc/povray/${version_dir}/ to ${EROOT}etc/povray/"
					break
				fi
			done
		fi
	done
}
