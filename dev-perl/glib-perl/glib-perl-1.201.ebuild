# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/glib-perl/glib-perl-1.201.ebuild,v 1.3 2009/04/06 14:40:02 armin76 Exp $

MODULE_AUTHOR=TSCH
MY_PN=Glib
MY_P=${MY_PN}-${PV}
inherit perl-module

DESCRIPTION="Glib - Perl wrappers for the GLib utility and Object libraries"
HOMEPAGE="http://gtk2-perl.sf.net/"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

RDEPEND=">=dev-libs/glib-2
	dev-lang/perl"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	>=dev-perl/extutils-pkgconfig-1.0
	>=dev-perl/extutils-depends-0.300"

S=${WORKDIR}/${MY_P}

SRC_TEST="do"
