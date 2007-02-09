# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/dev-util/intltool/intltool-0.35.4.ebuild,v 1.1 2007/01/22 22:16:52 leonardop Exp $

EAPI="prefix"

inherit gnome.org

DESCRIPTION="Tools for extracting translatable strings from various sourcefiles"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

DEPEND=">=dev-lang/perl-5.6
	dev-perl/XML-Parser"
RDEPEND="${DEPEND}"


src_install() {
	make DESTDIR="${D}" install || die "Installation failed"

	dodoc AUTHORS ChangeLog NEWS README TODO doc/I18N-HOWTO
}
