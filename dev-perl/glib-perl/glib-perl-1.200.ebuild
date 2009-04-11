# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/glib-perl/glib-perl-1.200.ebuild,v 1.3 2009/04/06 14:40:02 armin76 Exp $

inherit perl-module

MY_P=Glib-${PV}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Glib - Perl wrappers for the GLib utility and Object libraries"
HOMEPAGE="http://gtk2-perl.sf.net/"
SRC_URI="mirror://cpan/authors/id/T/TS/TSCH/${MY_P}.tar.gz"

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

SRC_TEST="do"
