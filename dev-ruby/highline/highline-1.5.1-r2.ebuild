# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/highline/highline-1.5.1-r2.ebuild,v 1.1 2009/12/25 13:57:27 a3li Exp $

EAPI=2

USE_RUBY="ruby18 ruby19 jruby"

RUBY_FAKEGEM_EXTRADOC="CHANGELOG README TODO"
RUBY_FAKEGEM_DOCDIR="doc/html"

inherit ruby-fakegem

DESCRIPTION="Highline is a high-level command-line IO library for ruby."
HOMEPAGE="http://rubyforge.org/projects/highline/"

IUSE=""
LICENSE="|| ( GPL-2 Ruby )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"

all_ruby_prepare() {
	sed -i -e '/AUTHORS/s:^:#:' Rakefile || die "Fixing the Rakefile failed"
}
