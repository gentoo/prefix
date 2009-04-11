# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/mechanize/mechanize-0.9.0.ebuild,v 1.3 2009/03/18 18:00:04 ranger Exp $

inherit ruby gems

DESCRIPTION="A Ruby library used for automating interaction with websites."
HOMEPAGE="http://mechanize.rubyforge.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-ruby/nokogiri-1.0.7
		>=dev-ruby/hoe-1.8.2
		>=dev-lang/ruby-1.8.4"
