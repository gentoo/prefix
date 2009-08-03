# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/xfconf/xfconf-4.6.1.ebuild,v 1.12 2009/08/02 10:16:31 ssuominen Exp $

EAPI=2
inherit flag-o-matic xfconf

DESCRIPTION="Xfce configuration daemon and utilities"
HOMEPAGE="http://www.xfce.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="debug -perl profile"

RDEPEND=">=dev-libs/dbus-glib-0.72
	>=dev-libs/glib-2.12:2
	>=xfce-base/libxfce4util-4.6
	perl? ( dev-perl/glib-perl )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool
	sys-devel/gettext
	perl? ( dev-perl/extutils-depends
		dev-perl/extutils-pkgconfig )"

RESTRICT="test"

pkg_setup() {
	XFCONF="--disable-dependency-tracking
		$(use_enable perl perl-bindings)
		$(use_enable debug)
		$(use_enable debug checks)"
	use profile && XFCONF="${XFCONF} --enable-profiling"
	DOCS="AUTHORS ChangeLog NEWS TODO"
}

src_configure() {
	use profile && filter-flags -fomit-frame-pointer
	xfconf_src_configure
}

src_compile() {
	emake OTHERLDFLAGS="${LDFLAGS}" || die "emake failed"
}

src_install() {
	xfconf_src_install

	if use perl; then
		find "${ED}" -type f -name perllocal.pod -delete
		find "${ED}" -depth -mindepth 1 -type d -empty -delete
	fi
}
