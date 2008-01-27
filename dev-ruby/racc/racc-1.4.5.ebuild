# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/racc/racc-1.4.5.ebuild,v 1.11 2007/07/11 05:23:08 mr_bones_ Exp $

EAPI="prefix"

inherit ruby

MY_P=${P}-all
DESCRIPTION="A LALR(1) parser generator for Ruby"
HOMEPAGE="http://www.loveruby.net/en/racc.html"
SRC_URI="http://www.loveruby.net/archive/racc/${MY_P}.tar.gz"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~ppc-macos"
USE_RUBY="ruby18 ruby19"
IUSE=""
S="${WORKDIR}/${MY_P}"

DEPEND=">=dev-lang/ruby-1.8"

src_install() {
	${RUBY} setup.rb install --prefix="${D}"
	erubydoc
}
