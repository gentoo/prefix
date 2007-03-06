# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/rake/rake-0.7.1.ebuild,v 1.8 2006/07/13 01:20:20 agriffis Exp $

EAPI="prefix"

inherit ruby gems

USE_RUBY="ruby18 ruby19"
DESCRIPTION="Make-like scripting in Ruby"
HOMEPAGE="http://rake.rubyforge.org/"
# The URL depends implicitly on the version, unfortunately. Even if you
# change the filename on the end, it still downloads the same file.
SRC_URI="http://rubyforge.org/frs/download.php/9498/${P}.gem
	http://rubyforge.org/frs/download.php/9499/${P}.tgz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""
RESTRICT="test"

src_unpack() {
	gems_src_unpack
	unpack ${P}.tgz
}

src_install() {
	#We install both sitelib and gem versions:
	gems_src_install
	cd ${WORKDIR}/${P}
	DESTDIR="$D" ruby install.rb || die
}
