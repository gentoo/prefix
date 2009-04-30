# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/gamin/gamin-0.1.10.ebuild,v 1.8 2009/04/28 18:14:30 armin76 Exp $

DESCRIPTION="Meta package providing the File Alteration Monitor API & Server"
HOMEPAGE="http://www.gnome.org/~veillard/gamin/"
SRC_URI=""

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="!app-admin/fam
	>=dev-libs/libgamin-0.1.10"
DEPEND=""

PDEPEND=">=app-admin/gam-server-0.1.10"

PROVIDE="virtual/fam"
