# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/mechanize/mechanize-0.9.2.ebuild,v 1.1 2009/05/10 18:41:27 a3li Exp $

inherit ruby gems

USE_RUBY="ruby18 ruby19"

DESCRIPTION="A Ruby library used for automating interaction with websites."
HOMEPAGE="http://mechanize.rubyforge.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-ruby/nokogiri-1.2.1
		>=dev-ruby/rubygems-1.3.1
		>=dev-lang/ruby-1.8.4"
RDEPEND="${DEPEND}"
