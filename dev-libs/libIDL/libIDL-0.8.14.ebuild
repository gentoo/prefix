# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libIDL/libIDL-0.8.14.ebuild,v 1.12 2013/03/03 14:59:34 pacho Exp $

EAPI=5
GNOME_TARBALL_SUFFIX="bz2"
GCONF_DEBUG="no"

inherit eutils gnome2 autotools

DESCRIPTION="CORBA tree builder"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND=">=dev-libs/glib-2.4:2"
DEPEND="sys-devel/flex
	virtual/yacc
	virtual/pkgconfig"

DOCS="AUTHORS BUGS ChangeLog HACKING MAINTAINERS NEWS README"
G2CONF="--disable-static"
