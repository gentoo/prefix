# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/ruby-postgres/ruby-postgres-0.7.9.20080128.ebuild,v 1.1 2008/06/26 06:38:02 robbat2 Exp $

inherit ruby gems versionator

# changes 0.7.1.20060406 to 0.7.1.2006.04.06

# ideally, PV would have been this to start with, but can't change it now as
# 0.7.1.20051221 > 0.7.1.2006.04.06.
MY_PV="0.7.9.2008.01.28"
MY_PN="postgres"
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="An extension library to access a PostgreSQL database from Ruby"
HOMEPAGE="http://ruby.scripting.ca/postgres"
SRC_URI="http://gems.rubyforge.org/gems/${MY_P}.gem"
LICENSE="Ruby"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""
USE_RUBY="ruby18"

RDEPEND="virtual/postgresql-base"
DEPEND="${RDEPEND}
	>=dev-ruby/rubygems-0.9.0-r1"
