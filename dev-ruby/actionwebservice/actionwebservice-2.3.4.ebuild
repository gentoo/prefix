# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/actionwebservice/actionwebservice-2.3.4.ebuild,v 1.1 2009/10/12 22:13:40 flameeyes Exp $

MY_OWNER="dougbarth"

MY_P="${MY_OWNER}-${P}"

inherit ruby gems

DESCRIPTION="Simple Support for Web Services APIs for Rails"
HOMEPAGE="http://github.com/datanoise/actionwebservice"
SRC_URI="http://gems.github.com/gems/${MY_P}.gem"

LICENSE="MIT"
SLOT="2.3"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND="=dev-ruby/actionpack-2.3*
	=dev-ruby/activerecord-2.3*"
RDEPEND="${DEPEND}"

USE_RUBY="ruby18"

GEMS_FORCE_INSTALL="yes"
