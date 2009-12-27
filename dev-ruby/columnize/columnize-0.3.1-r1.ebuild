# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/columnize/columnize-0.3.1-r1.ebuild,v 1.1 2009/12/22 07:55:43 graaff Exp $

EAPI=2
USE_RUBY="ruby18"

RUBY_FAKEGEM_EXTRADOC="AUTHORS ChangeLog NEWS README"

inherit ruby-fakegem

DESCRIPTION="Sorts an array in column order."
HOMEPAGE="http://rubyforge.org/projects/rocky-hacks/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE=""

ruby_add_bdepend test virtual/ruby-test-unit
