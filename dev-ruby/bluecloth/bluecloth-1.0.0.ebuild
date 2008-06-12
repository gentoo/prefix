# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/bluecloth/bluecloth-1.0.0.ebuild,v 1.11 2007/06/20 19:58:04 corsair Exp $

EAPI="prefix"

inherit ruby gems

MY_P="BlueCloth-${PV}"
DESCRIPTION="A Ruby implementation of Markdown"
HOMEPAGE="http://www.deveiate.org/projects/BlueCloth"
SRC_URI="http://www.deveiate.org/code/${MY_P}.gem"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

USE_RUBY="ruby18"
DEPEND=">=dev-lang/ruby-1.8"

S=${WORKDIR}/${MY_P}

pkg_postinst() {
	elog "This package was installed using a 'gem'."
	elog "If you are intending to write code which"
	elog "requires ${PN}, you will need to"
	elog
	elog "require 'rubygems'"
	elog
	elog "before requiring '${PN}'."
}
