# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/ruby-filemagic/ruby-filemagic-0.1.1.ebuild,v 1.6 2009/07/14 17:41:06 graaff Exp $

inherit ruby

USE_RUBY="ruby18"

DESCRIPTION="Ruby binding to libmagic"
HOMEPAGE="http://grub.ath.cx/filemagic/"
SRC_URI="http://grub.ath.cx/filemagic/${P}.tar.gz"

LICENSE="Ruby"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND="virtual/ruby
		sys-apps/file"
#RDEPEND="${DEPEND}"

src_compile() {
	ruby extconf.rb || die
	emake || die
}

src_install() {
	ruby_einstall || die
	dodoc filemagic.rd
}
