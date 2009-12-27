# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/bluecloth/bluecloth-2.0.5-r1.ebuild,v 1.1 2009/12/15 15:09:31 flameeyes Exp $

EAPI=2
USE_RUBY="ruby18 ruby19"

inherit ruby-fakegem eutils

DESCRIPTION="A Ruby implementation of Markdown"
HOMEPAGE="http://www.deveiate.org/projects/BlueCloth"
SRC_URI="http://www.deveiate.org/code/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

ruby_add_bdepend ">=dev-ruby/rdoc-2.4.1"
ruby_add_bdepend test "dev-ruby/rspec
		dev-ruby/diff-lcs"

each_ruby_compile() {
	${RUBY} -S rake ext/Makefile || die

	emake -C ext || die
}

each_ruby_install() {
	each_fakegem_install
	ruby_fakegem_newins ext/bluecloth_ext.so lib/bluecloth_ext.so
}

all_ruby_install() {
	ruby_fakegem_binwrapper bluecloth
	dodoc ChangeLog README || die

	if use doc; then
		pushd docs/api
		dohtml -r * || die
		popd
	fi
}
