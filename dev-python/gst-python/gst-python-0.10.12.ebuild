# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/gst-python/gst-python-0.10.12.ebuild,v 1.1 2008/06/29 19:07:05 drac Exp $

EAPI="prefix"

NEED_PYTHON=2.4

inherit autotools eutils multilib python

DESCRIPTION="A Python Interface to GStreamer"
HOMEPAGE="http://gstreamer.freedesktop.org"
SRC_URI="http://gstreamer.freedesktop.org/src/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2"
SLOT="0.10"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE="examples"

RDEPEND=">=dev-python/pygtk-2.6.3
	>=dev-libs/glib-2.8
	>=x11-libs/gtk+-2.6
	>=dev-python/pygobject-2.11.2
	>=media-libs/gstreamer-0.10.12
	>=media-libs/gst-plugins-base-0.10.12
	dev-libs/libxml2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.10.9-lazy.patch

	rm -f py-compile || die "rm failed."
	ln -s $(type -P true) py-compile || die "ln failed."

	AT_M4DIR="common/m4" eautoreconf
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README TODO

	if use examples; then
		docinto examples
		dodoc examples/*
	fi
}

pkg_postinst() {
	python_version
	python_mod_compile /usr/$(get_libdir)/python${PYVER}/site-packages/pygst.py
	python_mod_optimize	/usr/$(get_libdir)/python${PYVER}/site-packages/gst-0.10
}

pkg_postrm() {
	python_mod_cleanup
}
