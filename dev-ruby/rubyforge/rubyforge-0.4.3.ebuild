# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/rubyforge/rubyforge-0.4.3.ebuild,v 1.4 2007/10/14 04:48:08 tgall Exp $

EAPI="prefix"

inherit ruby gems

DESCRIPTION="Simplistic script which automates a limited set of rubyforge operations"
HOMEPAGE="http://codeforpeople.com/lib/ruby/rubyforge/"
SRC_URI="http://gems.rubyforge.org/gems/${P}.gem"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

USE_RUBY="ruby18"

DEPEND=">=dev-lang/ruby-1.8.4"
