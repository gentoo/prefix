# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-rails/eselect-rails-0.10.ebuild,v 1.7 2007/10/21 15:23:42 beandog Exp $

EAPI="prefix"

DESCRIPTION="Manages Ruby on Rails symlinks"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
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
