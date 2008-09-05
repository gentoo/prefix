# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/hoe/hoe-1.7.0.ebuild,v 1.4 2008/09/03 18:41:34 graaff Exp $

EAPI="prefix"

inherit gems

DESCRIPTION="Hoe extends rake to provide full project automation."
HOMEPAGE="http://seattlerb.rubyforge.org/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-ruby/rake-0.8.1
	>=dev-ruby/rubyforge-1.0.0
	>=dev-ruby/rubygems-1.2.0"
