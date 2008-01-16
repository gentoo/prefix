# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/mechanize/mechanize-0.6.7.ebuild,v 1.2 2007/04/14 20:57:47 robbat2 Exp $

EAPI="prefix"

inherit ruby gems

DESCRIPTION="The Mechanize library is used for automating interaction with websites."
HOMEPAGE="http://mechanize.rubyforge.org/"
SRC_URI="http://gems.rubyforge.org/gems/${P}.gem"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

USE_RUBY="ruby18"

DEPEND="dev-ruby/hpricot
		>=dev-ruby/hoe-1.2.0
		>=dev-lang/ruby-1.8.2"
