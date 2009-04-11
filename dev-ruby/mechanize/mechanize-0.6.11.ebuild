# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/mechanize/mechanize-0.6.11.ebuild,v 1.1 2007/12/06 00:04:02 agorf Exp $

inherit ruby gems

DESCRIPTION="A Ruby library used for automating interaction with websites."
HOMEPAGE="http://mechanize.rubyforge.org/"
SRC_URI="http://gems.rubyforge.org/gems/${P}.gem"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

USE_RUBY="ruby18"

DEPEND=">=dev-ruby/hpricot-0.5.0
		>=dev-ruby/hoe-1.3.0
		>=dev-lang/ruby-1.8.2"
