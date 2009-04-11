# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/gstreamer/gstreamer-0.10.20.ebuild,v 1.10 2009/04/05 17:43:40 armin76 Exp $

inherit libtool eutils

# Create a major/minor combo for our SLOT and executables suffix
PVP=(${PV//[-\._]/ })
PV_MAJ_MIN=${PVP[0]}.${PVP[1]}
#PV_MAJ_MIN=0.10

DESCRIPTION="Streaming media framework"
HOMEPAGE="http://gstreamer.sourceforge.net"
SRC_URI="http://${PN}.freedesktop.org/src/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2"
SLOT=${PV_MAJ_MIN}
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE="debug nls test"

RDEPEND=">=dev-libs/glib-2.12
	>=dev-libs/libxml2-2.4.9
	>=dev-libs/check-0.9.2"
DEPEND="${RDEPEND}
	nls? ( >=sys-devel/gettext-0.11.5 )
	dev-util/pkgconfig
	!<media-libs/gst-plugins-ugly-0.10.6-r1
	!=media-libs/gst-plugins-good-0.10.8"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-0.10.17-interix.patch
	epatch "${FILESDIR}"/${PN}-0.10.19-interix.patch

	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${P}-interix3.patch

	# Needed for sane .so versioning on Gentoo/FreeBSD
	elibtoolize
}

src_compile() {
	if [[ ${CHOST} == *-interix* ]] ; then
		export ac_cv_lib_dl_dladdr=no
		export ac_cv_func_poll=no
	fi

	econf --disable-dependency-tracking \
		--with-package-name="Gentoo GStreamer ebuild" \
		--with-package-origin="http://www.gentoo.org" \
		$(use_enable test tests) \
		$(use_enable debug valgrind) \
		$(use_enable debug) \
		$(use_enable nls)

	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README RELEASE

	# Remove unversioned binaries to allow SLOT installations in future.
	cd "${ED}"/usr/bin
	local gst_bins
	for gst_bins in $(ls *-${PV_MAJ_MIN}) ; do
		rm ${gst_bins/-${PV_MAJ_MIN}/}
		einfo "Removed ${gst_bins/-${PV_MAJ_MIN}/}"
	done

	cd "${S}"
	dodoc AUTHORS ChangeLog NEWS README RELEASE TODO

	echo "PRELINK_PATH_MASK=${EPREFIX}/usr/lib/${PN}-${PV_MAJ_MIN}" > 60${PN}-${PV_MAJ_MIN}
	doenvd 60${PN}-${PV_MAJ_MIN}
}

pkg_postinst() {
	elog "Gstreamer has known problems with prelinking, as a workaround"
	elog "this ebuild adds the gstreamer plugins to the prelink mask"
	elog "path to stop them from being prelinked. It is imperative"
	elog "that you undo & redo prelinking after building this pack for"
	elog "this to take effect. Make sure the gstreamer lib path is indeed"
	elog "added to the PRELINK_PATH_MASK environment variable."
	elog "For more information see http://bugs.gentoo.org/81512"
}
