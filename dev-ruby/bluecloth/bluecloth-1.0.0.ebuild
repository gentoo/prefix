# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/bluecloth/bluecloth-1.0.0.ebuild,v 1.13 2009/11/29 14:33:44 a3li Exp $

inherit ruby gems

MY_P="BlueCloth-${PV}"
DESCRIPTION="A Ruby implementation of Markdown"
HOMEPAGE="http://www.deveiate.org/projects/BlueCloth"
SRC_URI="mirror://gentoo/${MY_P}.gem"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

USE_RUBY="ruby18"
DEPEND=">=dev-lang/ruby-1.8"

S=${WORKDIR}/${MY_P}
