# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/hoe/hoe-1.8.0.ebuild,v 1.1 2008/10/14 07:02:20 graaff Exp $

EAPI="prefix"

inherit gems

DESCRIPTION="Hoe extends rake to provide full project automation."
HOMEPAGE="http://seattlerb.rubyforge.org/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-ruby/rake-0.8.3
	>=dev-ruby/rubyforge-1.0.0
	>=dev-ruby/rubygems-1.2.0"
