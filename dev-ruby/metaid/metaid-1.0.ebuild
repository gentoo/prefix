# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/metaid/metaid-1.0.ebuild,v 1.5 2007/10/13 06:16:36 tgall Exp $

EAPI="prefix"

inherit ruby gems

USE_RUBY="ruby18"
DESCRIPTION="An aid to Ruby metaprogramming"
HOMEPAGE="http://rubyforge.org/projects/metaid/"
SRC_URI="http://gems.rubyforge.org/gems/${P}.gem"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""
RESTRICT="test"

DEPEND=">=dev-lang/ruby-1.8.2"
