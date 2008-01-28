# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/ruby-romkan/ruby-romkan-0.4-r1.ebuild,v 1.14 2004/10/23 08:04:21 mr_bones_ Exp $

EAPI="prefix"

inherit ruby

DESCRIPTION="A Romaji <-> Kana conversion library for Ruby"
HOMEPAGE="http://namazu.org/~satoru/ruby-romkan/"
SRC_URI="http://namazu.org/~satoru/ruby-romkan/${P}.tar.gz"
LICENSE="Ruby"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~ppc-macos"
IUSE=""
DEPEND="virtual/ruby"

src_test() {
	./test.sh || die "test failed"
	rm test.rb
}
