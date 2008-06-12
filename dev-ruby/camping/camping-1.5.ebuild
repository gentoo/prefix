# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/camping/camping-1.5.ebuild,v 1.2 2007/10/13 06:18:42 tgall Exp $

EAPI="prefix"

inherit ruby gems

USE_RUBY="ruby18"

DESCRIPTION="A web microframework inspired by Ruby on Rails."
HOMEPAGE="http://code.whytheluckystiff.net/camping/"
SRC_URI="http://gems.rubyforge.org/gems/${P}.gem"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND=">=dev-lang/ruby-1.8.2
	>=dev-ruby/markaby-0.5
	>=dev-ruby/metaid-1.0
	>=dev-ruby/activerecord-1.14.2"
