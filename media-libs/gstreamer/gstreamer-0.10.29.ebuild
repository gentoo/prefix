# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/gstreamer/gstreamer-0.10.29.ebuild,v 1.4 2010/08/03 21:32:46 maekke Exp $

EAPI=2

inherit eutils multilib versionator

# Create a major/minor combo for our SLOT and executables suffix
PV_MAJ_MIN=$(get_version_component_range '1-2')

DESCRIPTION="Streaming media framework"
HOMEPAGE="http://gstreamer.sourceforge.net"
SRC_URI="http://${PN}.freedesktop.org/src/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2"
SLOT=${PV_MAJ_MIN}
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="nls test"

RDEPEND=">=dev-libs/glib-2.18:2
	dev-libs/libxml2
	!<media-libs/gst-plugins-base-0.10.26"
	# ^^ queue2 move, mustn't have both libgstcoreleements.so and libgstqueue2.so at runtime providing the element at once
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	nls? ( sys-devel/gettext )"

src_configure() {
	if [[ ${CHOST} == *-interix* ]] ; then
		export ac_cv_lib_dl_dladdr=no
		export ac_cv_func_poll=no
	fi
	if [[ ${CHOST} == powerpc-apple-darwin* ]] ; then
		# GCC groks this, but then refers to an implementation (___multi3,
		# ___udivti3) that don't exist (at least I can't find it), so force
		# this one to be off, such that we use 2x64bit emulation code.
		export gst_cv_uint128_t=no
	fi

	# PREFIX: for some reason Debug is on by default, which causes
	# -g to be injected in CFLAGS, which in turn causes gcc to generate code
	# that the assembler segfaults on (yay) on Darwin, so disable it using
	# --disable-debug

	# Disable static archives, dependency tracking and examples
	# to speed up build time
	econf \
		--disable-static \
		--disable-dependency-tracking \
		$(use_enable nls) \
		--disable-valgrind \
		--disable-examples \
		--disable-debug \
		--enable-check \
		--disable-introspection \
		$(use_enable test tests) \
		--with-package-name="GStreamer ebuild for Gentoo" \
		--with-package-origin="http://packages.gentoo.org/package/media-libs/gstreamer"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS MAINTAINERS README RELEASE

	# Remove unversioned binaries to allow SLOT installations in future
	cd "${ED}"/usr/bin
	local gst_bins
	for gst_bins in $(ls *-${PV_MAJ_MIN}); do
		rm -f ${gst_bins/-${PV_MAJ_MIN}/}
	done
}
