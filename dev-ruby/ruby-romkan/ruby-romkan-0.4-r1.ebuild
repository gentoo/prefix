# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/ruby-romkan/ruby-romkan-0.4-r1.ebuild,v 1.15 2008/01/27 20:05:57 grobian Exp $

EAPI="prefix"

inherit ruby

DESCRIPTION="A Romaji <-> Kana conversion library for Ruby"
HOMEPAGE="http://namazu.org/~satoru/ruby-romkan/"
SRC_URI="http://namazu.org/~satoru/ruby-romkan/${P}.tar.gz"
LICENSE="Ruby"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""
DEPEND="virtual/ruby"

src_test() {
	./test.sh || die "test failed"
	rm test.rb
}
