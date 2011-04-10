# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-rails/eselect-rails-0.16.ebuild,v 1.1 2010/09/10 10:25:24 graaff Exp $

DESCRIPTION="Manages Ruby on Rails symlinks"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND=">=app-admin/eselect-1.0.10"

src_unpack() {
	unpack ${A}
	# fix for prefix
	sed -i -e 's|${ROOT}|${EROOT}|g' rails.eselect || die
}

src_install() {
	insinto /usr/share/eselect/modules
	doins *.eselect || die "doins failed"
}
