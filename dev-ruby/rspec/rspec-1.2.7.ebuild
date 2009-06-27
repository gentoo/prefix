# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/rspec/rspec-1.2.7.ebuild,v 1.1 2009/06/23 05:07:29 graaff Exp $

inherit gems

DESCRIPTION="A Behaviour Driven Development (BDD) framework for Ruby"
HOMEPAGE="http://rspec.rubyforge.org/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

USE_RUBY="ruby18 ruby19"

RDEPEND=">=dev-ruby/rubygems-1.3.0"
