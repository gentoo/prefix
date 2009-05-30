# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-rails/eselect-rails-0.15.ebuild,v 1.7 2009/05/28 16:10:07 armin76 Exp $

DESCRIPTION="Manages Ruby on Rails symlinks"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

RDEPEND=">=app-admin/eselect-1.0.10"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# "fix" for prefix
	sed -i -e "s|\${ROOT}|\${ROOT}${EPREFIX}|g" rails.eselect || die
}

src_install() {
	insinto /usr/share/eselect/modules
	doins *.eselect || die "doins failed"
}
