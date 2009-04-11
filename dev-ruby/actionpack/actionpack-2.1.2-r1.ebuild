# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/actionpack/actionpack-2.1.2-r1.ebuild,v 1.5 2009/03/25 14:55:43 armin76 Exp $

inherit eutils ruby gems

DESCRIPTION="Eases web-request routing, handling, and response."
HOMEPAGE="http://rubyforge.org/projects/actionpack/"

LICENSE="MIT"
SLOT="2.1"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-lang/ruby-1.8.5
	=dev-ruby/activesupport-2.1.2"

src_install() {
	gems_src_install

	# Patch for bug 247579.
	# Yes, I know, but we cannot patch gems in a different way *yet*.
	cd "${ED}/$(gem18 env gemdir)/gems/${P}/lib" || die "cd failed"
	epatch "${FILESDIR}/${PV}-csrf-circumvention.patch"
}
