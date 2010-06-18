# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/povray/povray-3.6.1-r4.ebuild,v 1.9 2010/05/15 16:22:12 ssuominen Exp $

inherit flag-o-matic eutils autotools

DESCRIPTION="The Persistence Of Vision Ray Tracer"
SRC_URI="ftp://ftp.povray.org/pub/povray/Official/Unix/${P}.tar.bz2"
HOMEPAGE="http://www.povray.org/"

LICENSE="povlegal-3.6"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="svga tiff X"

DEPEND="media-libs/libpng
	tiff? ( >=media-libs/tiff-3.6.1 )
	media-libs/jpeg
	sys-libs/zlib
	X? ( x11-libs/libXaw )
	svga? ( media-libs/svgalib )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	has_version ">=media-libs/libpng-1.4" && epatch \
		"${FILESDIR}"/${P}-libpng14.patch

	epatch "${FILESDIR}"/${P}-configure.patch
	epatch "${FILESDIR}"/${P}-find-egrep.patch

	# Change some destination directories that cannot be adjusted via configure
	cp Makefile.am Makefile.am.orig
	sed -i -e "s:^povlibdir = .*:povlibdir = @datadir@/${PN}:" Makefile.am
	sed -i -e "s:^povdocdir = .*:povdocdir = @datadir@/doc/${PF}:" Makefile.am
	sed -i -e "s:^povconfdir = .*:povconfdir = @sysconfdir@/${PN}:" Makefile.am

	cd unix
	cp Makefile.am Makefile.am.orig
	sed -i -e 's:^  -DPOVLIBDIR=.*:  -DPOVLIBDIR=\\"@datadir@/'"${PN}"'\\" \\:' Makefile.am
	sed -i -e 's:^  -DPOVCONFDIR=.*:  -DPOVCONFDIR=\\"@sysconfdir@/'"${PN}"'\\" \\:' Makefile.am
	cd ..

	# Patch code that compares system lib versions to properly detect
	# newer versions.  Also fix reference to old png call.  (Bug #153538)
	epatch "${FILESDIR}"/${P}-use-system-libpng.patch

	# Also, to make sure no bundled static libs can be used, remove them
	rm -r libraries/jpeg
	rm -r libraries/png
	rm -r libraries/tiff
	rm -r libraries/zlib

	AT_NO_RECURSIVE="yes" eautoreconf
}

src_compile() {
	# Fixes bug 71255
	if [[ $(get-flag march) == k6-2 ]]; then
		filter-flags -fomit-frame-pointer
	fi

	econf \
		COMPILED_BY="Portage (Gentoo `uname`) on `hostname -f`" \
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
