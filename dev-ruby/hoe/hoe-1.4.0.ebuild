# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/hoe/hoe-1.4.0.ebuild,v 1.6 2008/03/15 09:04:14 nixnut Exp $

EAPI="prefix"

inherit ruby gems

DESCRIPTION="Hoe extends rake to provide full project automation."
HOMEPAGE="http://seattlerb.rubyforge.org/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-lang/ruby-1.8.4
	>=dev-ruby/rake-0.7.3
	>=dev-ruby/rubyforge-0.4.4"
