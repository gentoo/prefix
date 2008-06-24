# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/xfce4-dev-tools/xfce4-dev-tools-4.4.0.1.ebuild,v 1.1 2008/06/22 23:56:03 drac Exp $

EAPI="prefix"

DESCRIPTION="m4macros for autotools eclass and subversion builds"
HOMEPAGE="http://foo-projects.org/~benny/projects/xfce4-dev-tools"
SRC_URI="mirror://xfce/xfce-4.4.2/src/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog HACKING NEWS README
}
# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/xfce4-dev-tools/xfce4-dev-tools-4.4.0.1.ebuild,v 1.1 2008/06/22 23:56:03 drac Exp $

EAPI="prefix"

inherit xfce44

xfce44

DESCRIPTION="m4macros for autotools eclass and subversion builds"
HOMEPAGE="http://foo-projects.org/~benny/projects/xfce4-dev-tools"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"

RDEPEND=""
DEPEND=""

DOCS="AUTHORS ChangeLog HACKING NEWS README"

xfce44_core_package
