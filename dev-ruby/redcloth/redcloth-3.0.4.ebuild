# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/redcloth/redcloth-3.0.4.ebuild,v 1.11 2009/04/14 17:31:40 graaff Exp $

inherit ruby gems

MY_P="RedCloth-${PV}"
DESCRIPTION="A module for using Textile in Ruby"
HOMEPAGE="http://www.whytheluckystiff.net/ruby/redcloth/"
SRC_URI="http://gems.rubyforge.org/gems/${MY_P}.gem"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

USE_RUBY="ruby18"
DEPEND="virtual/ruby"

S=${WORKDIR}/${MY_P}

pkg_postinst() {
	elog "NOTE: This package is now installed via a 'gem'."
	elog "Previous versions used a standard tarball."
	elog "No packages in portage required ${PN}, so you won't be affected unless"
	elog "you have written ruby code which requires ${PN}. In that case you'll need"
	elog "to add this:"
	elog
	elog "require 'rubygems'"
	elog
	elog "before:"
	elog "require '${PN}'"
}
