# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/ruby-bsearch/ruby-bsearch-1.5-r1.ebuild,v 1.15 2007/02/03 21:43:14 flameeyes Exp $

EAPI="prefix"

inherit ruby

DESCRIPTION="A binary search library for Ruby"
HOMEPAGE="http://0xcc.net/ruby-bsearch/"
SRC_URI="http://0xcc.net/ruby-bsearch/${P}.tar.gz"
LICENSE="Ruby"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~ppc-macos"
IUSE=""
USE_RUBY="any"
DEPEND="dev-lang/ruby"

DOCS="ChangeLog *.rd bsearch.png"
