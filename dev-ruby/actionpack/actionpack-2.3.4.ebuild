# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/actionpack/actionpack-2.3.4.ebuild,v 1.5 2009/09/25 18:22:36 ranger Exp $

inherit ruby gems
USE_RUBY="ruby18 ruby19"

DESCRIPTION="Eases web-request routing, handling, and response."
HOMEPAGE="http://rubyforge.org/projects/actionpack/"

LICENSE="MIT"
SLOT="2.3"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=">=dev-lang/ruby-1.8.6
	=dev-ruby/activesupport-2.3.4
	=dev-ruby/rack-1.0*"
RDEPEND="${DEPEND}"
