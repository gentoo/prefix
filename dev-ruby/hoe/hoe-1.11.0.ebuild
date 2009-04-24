# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/hoe/hoe-1.11.0.ebuild,v 1.2 2009/04/22 10:01:53 graaff Exp $

inherit gems

USE_RUBY="ruby18 ruby19"

DESCRIPTION="Hoe extends rake to provide full project automation."
HOMEPAGE="http://seattlerb.rubyforge.org/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-ruby/rake-0.8.4
	>=dev-ruby/rubyforge-1.0.3
	>=dev-ruby/rubygems-1.2.0"
