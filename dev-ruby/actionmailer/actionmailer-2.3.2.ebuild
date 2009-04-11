# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/actionmailer/actionmailer-2.3.2.ebuild,v 1.1 2009/03/17 10:39:04 a3li Exp $

inherit ruby gems
USE_RUBY="ruby18 ruby19"

DESCRIPTION="Framework for designing email-service layers"
HOMEPAGE="http://rubyforge.org/projects/actionmailer/"

LICENSE="MIT"
SLOT="2.3"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND="~dev-ruby/actionpack-2.3.2
	>=dev-lang/ruby-1.8.6"
