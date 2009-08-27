# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/ruby-romkan/ruby-romkan-0.4-r1.ebuild,v 1.17 2009/08/24 20:04:20 graaff Exp $

inherit ruby

DESCRIPTION="A Romaji <-> Kana conversion library for Ruby"
HOMEPAGE="http://0xcc.net/ruby-romkan/"
SRC_URI="http://0xcc.net/ruby-romkan/${P}.tar.gz"
LICENSE="Ruby"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

src_test() {
	./test.sh || die "test failed"
}

src_install() {
	rm test.rb
	ruby_src_install
}
