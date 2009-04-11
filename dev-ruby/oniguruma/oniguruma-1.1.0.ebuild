# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/oniguruma/oniguruma-1.1.0.ebuild,v 1.3 2007/06/26 02:01:14 mr_bones_ Exp $

inherit ruby gems

USE_RUBY="ruby18"
DESCRIPTION="Ruby bindings to the Oniguruma"
HOMEPAGE="http://oniguruma.rubyforge.org/"
SRC_URI="http://gems.rubyforge.org/gems/${P}.gem"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-lang/ruby-1.8.5
	dev-libs/oniguruma"
