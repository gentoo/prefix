# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/mongrel/mongrel-1.0.1.ebuild,v 1.7 2007/11/12 14:19:23 armin76 Exp $

EAPI="prefix"

inherit ruby gems

DESCRIPTION="A small fast HTTP library and server that runs Rails, Camping, and Nitro apps"
HOMEPAGE="http://mongrel.rubyforge.org/"
SRC_URI="http://mongrel.rubyforge.org/releases/gems/${P}.gem"

LICENSE="mongrel"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

USE_RUBY="any"
DEPEND=">=dev-ruby/daemons-1.0.3
	>=dev-ruby/gem_plugin-0.2.1
	>=dev-ruby/fastthread-0.6.2
	>=dev-ruby/cgi_multipart_eof_fix-0.2.1"
