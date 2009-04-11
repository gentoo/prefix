# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/gem_plugin/gem_plugin-0.2.2.ebuild,v 1.11 2007/03/05 23:53:47 rbrown Exp $

inherit ruby gems

USE_RUBY="ruby18"
DESCRIPTION="A plugin system based only on rubygems that uses dependencies only."
# Mongrel hosts gem_plugin, so setting that as homepage
HOMEPAGE="http://mongrel.rubyforge.org/"

# Upstream changed one line in the rake file with no version bump
# SRC_URI="http://mongrel.rubyforge.org/releases/gems/${P}.gem"
SRC_URI="mirror://gentoo/${P}.gem"

LICENSE="mongrel"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND=">=dev-ruby/rake-0.7"
