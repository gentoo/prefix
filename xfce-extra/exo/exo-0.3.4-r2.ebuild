# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/exo/exo-0.3.4-r2.ebuild,v 1.8 2009/02/04 21:16:09 armin76 Exp $

inherit eutils xfce44 python multilib autotools

XFCE_VERSION=4.4.2
xfce44
xfce44_core_package

DESCRIPTION="Extensions, widgets and framework library with session management support"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x64-solaris ~x86-solaris"
IUSE="debug doc hal libnotify python"

RDEPEND=">=dev-lang/perl-5.6
	dev-perl/URI
	>=dev-libs/glib-2.6
	>=x11-libs/gtk+-2.6
	>=xfce-base/libxfce4util-${XFCE_MASTER_VERSION}
	>=xfce-base/xfce-mcs-manager-${XFCE_MASTER_VERSION}
	>=xfce-base/xfce-mcs-plugins-${XFCE_MASTER_VERSION}
	libnotify? ( x11-libs/libnotify )
	hal? ( >=sys-apps/hal-0.5.7.1 )
	python? ( dev-python/pygtk )"
DEPEND="${RDEPEND}
	|| ( dev-util/gtk-doc-am <dev-util/gtk-doc-1.10-r1 )
	dev-util/pkgconfig
	dev-util/xfce4-dev-tools
	doc? ( dev-util/gtk-doc )
	dev-util/intltool"

DOCS="AUTHORS ChangeLog HACKING NEWS README THANKS TODO"

pkg_setup() {
	XFCE_CONFIG="${XFCE_CONFIG}	$(use_enable python)
		$(use_enable libnotify notifications)
		$(use_enable hal) --enable-mcs-plugin"
}

# See bug 166568 for reference
src_unpack() {
	unpack ${A}
	cd "${S}"

	sed -i -e 's:-Werror::g' "${S}"/configure.in || die "sed failed"
	epatch "${FILESDIR}"/${P}-eject.patch \
		"${FILESDIR}"/${P}-remove-libmd5.patch \
		"${FILESDIR}"/${P}-inline-functions.patch
	intltoolize --force --copy --automake || die "intltoolize failed."
	AT_M4DIR="${EPREFIX}"/usr/share/xfce4/dev-tools/m4macros eautoreconf

	epatch "${FILESDIR}"/${P}-interix.patch
}

src_compile() {
	[[ ${CHOST} == *-interix* ]] && {
		# configure detects getmntent, which is false!
		export ac_cv_func_getmntent=no
	}

	xfce44_src_compile
}

# See bug 164780 for reference
src_install() {
	xfce44_src_install
	rm -f "${ED}"/usr/lib*/python*/site-packages/pyexo.py[co]
	rm -f "${ED}"/usr/lib*/python*/site-packages/${PN}-0.3/${PN}/__init__.py[co]
}

pkg_postinst() {
	xfce44_pkg_postinst
	python_version
	python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages
}

pkg_postrm() {
	xfce44_pkg_postrm
	python_mod_cleanup
}
