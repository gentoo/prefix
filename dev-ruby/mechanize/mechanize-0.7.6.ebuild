# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/mechanize/mechanize-0.7.6.ebuild,v 1.3 2008/07/08 01:54:38 the_paya Exp $

inherit ruby gems

DESCRIPTION="A Ruby library used for automating interaction with websites."
HOMEPAGE="http://mechanize.rubyforge.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-ruby/hpricot-0.5.0
		>=dev-ruby/hoe-1.5.1
		>=dev-lang/ruby-1.8.4"
