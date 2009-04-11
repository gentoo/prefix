# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/camping/camping-1.5-r1.ebuild,v 1.1 2008/01/18 07:05:12 agorf Exp $

inherit ruby gems

DESCRIPTION="A small web framework modeled after Ruby on Rails."
HOMEPAGE="http://code.whytheluckystiff.net/camping/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="mongrel"

DEPEND=">=dev-lang/ruby-1.8.2
	>=dev-ruby/markaby-0.5
	>=dev-ruby/metaid-1.0
	>=dev-ruby/activerecord-1.14.2
	mongrel? ( www-servers/mongrel )"
