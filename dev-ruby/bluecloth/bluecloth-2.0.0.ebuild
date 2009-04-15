# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/bluecloth/bluecloth-2.0.0.ebuild,v 1.1 2009/04/14 16:14:42 a3li Exp $

inherit ruby gems

DESCRIPTION="A Ruby implementation of Markdown"
HOMEPAGE="http://www.deveiate.org/projects/BlueCloth"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

USE_RUBY="ruby18 ruby19"
DEPEND=">=dev-lang/ruby-1.8"
RDEPEND="${DEPEND}"
