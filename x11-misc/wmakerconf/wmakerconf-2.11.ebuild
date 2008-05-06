# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/wmakerconf/wmakerconf-2.11.ebuild,v 1.10 2007/07/13 05:09:41 mr_bones_ Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="X based config tool for the windowmaker X windowmanager."
SRC_URI="http://www.starplot.org/wmakerconf/${P}.tar.gz"
HOMEPAGE="http://www.starplot.org/wmakerconf/"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~x86-linux"

IUSE="nls imlib perl"

DEPEND="=x11-libs/gtk+-2*
	dev-util/pkgconfig
	>=x11-wm/windowmaker-0.90.0
	imlib? ( media-libs/imlib )"

RDEPEND="${DEPEND}
	nls? ( sys-devel/gettext )
	perl? ( dev-lang/perl
		dev-perl/HTML-Parser
		dev-perl/libwww-perl
		www-client/lynx
		net-misc/wget )"

src_compile() {
	local myconf

	use nls	|| myconf="${myconf} --disable-nls"
	use imlib || myconf="${myconf} --disable-imlibtest"
	if use perl; then
		myconf="${myconf} --enable-upgrade"
	fi

	econf ${myconf} || die "configure failed"
	emake || die "make failed"
}

src_install() {
	emake DESTDIR=${D} \
		gnulocaledir=${ED}/usr/share/locale \
		install || die "install failed"

	dodoc README NEWS MANUAL AUTHORS TODO ChangeLog
	doman man/*
}
