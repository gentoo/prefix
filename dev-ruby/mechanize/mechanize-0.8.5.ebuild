# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/mechanize/mechanize-0.8.5.ebuild,v 1.1 2008/12/20 13:51:18 graaff Exp $

inherit ruby gems

DESCRIPTION="A Ruby library used for automating interaction with websites."
HOMEPAGE="http://mechanize.rubyforge.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-ruby/hpricot-0.5.0
		>=dev-ruby/hoe-1.8.2
		>=dev-lang/ruby-1.8.4"
