# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/wmakerconf/wmakerconf-2.11.ebuild,v 1.11 2008/05/06 13:44:09 drac Exp $

DESCRIPTION="X based config tool for the windowmaker X windowmanager."
SRC_URI="http://www.starplot.org/wmakerconf/${P}.tar.gz"
HOMEPAGE="http://www.starplot.org/wmakerconf/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="nls imlib perl"

RDEPEND="=x11-libs/gtk+-2*
	>=x11-wm/windowmaker-0.90.0
	imlib? ( media-libs/imlib )
	perl? ( dev-lang/perl
		dev-perl/HTML-Parser
		dev-perl/libwww-perl
		www-client/lynx
		net-misc/wget )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	dev-util/pkgconfig"

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
	emake DESTDIR="${D}" \
		gnulocaledir="${ED}"/usr/share/locale \
		install || die "install failed"

	dodoc README NEWS MANUAL AUTHORS TODO ChangeLog
	doman man/*
}
