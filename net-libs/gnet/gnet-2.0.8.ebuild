# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/gnet/gnet-2.0.8.ebuild,v 1.6 2008/08/09 14:23:45 coldwind Exp $

inherit gnome2 eutils

DESCRIPTION="A simple network library."
HOMEPAGE="http://www.gnetlibrary.org/"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x86-solaris"

IUSE="doc test"

# FIXME: network-tests & use of valgrind

RDEPEND=">=dev-libs/glib-2.6"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? ( >=dev-util/gtk-doc-1.2 )
	test? ( >=dev-libs/check-0.9.4 )"

DOCS="AUTHORS BUGS ChangeLog HACKING NEWS README* TODO"
