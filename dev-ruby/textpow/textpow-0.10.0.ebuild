# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/textpow/textpow-0.10.0.ebuild,v 1.2 2007/06/26 02:01:36 mr_bones_ Exp $

inherit ruby gems

USE_RUBY="ruby18"
DESCRIPTION="A library to parse and process Textmate bundles."
HOMEPAGE="http://textpow.rubyforge.org/"
SRC_URI="http://gems.rubyforge.org/gems/${P}.gem"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-lang/ruby-1.8.5
	>=dev-ruby/oniguruma-1.1.0
	>=dev-ruby/plist-3.0.0"
