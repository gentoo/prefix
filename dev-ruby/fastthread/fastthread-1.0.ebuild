# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/fastthread/fastthread-1.0.ebuild,v 1.6 2007/10/13 05:12:57 tgall Exp $

inherit ruby gems

USE_RUBY="ruby18"
DESCRIPTION="Optimized replacement for thread.rb primitives"
# Mongrel hosts gem_plugin, so setting that as homepage
HOMEPAGE="http://mongrel.rubyforge.org/"
SRC_URI="http://mongrel.rubyforge.org/releases/gems/${P}.gem"

LICENSE="Ruby"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""
