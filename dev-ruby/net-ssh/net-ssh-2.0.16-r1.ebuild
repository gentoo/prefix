# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/net-ssh/net-ssh-2.0.16-r1.ebuild,v 1.1 2010/01/06 07:30:34 graaff Exp $

EAPI="2"
USE_RUBY="ruby18"

RUBY_FAKEGEM_TASK_DOC=""  # Uses hanna which we don't have yet.
RUBY_FAKEGEM_TASK_TEST="" # Tests depend on test-unit-2.x which is masked.

RUBY_FAKEGEM_EXTRADOC="CHANGELOG.rdoc README.rdoc THANKS.rdoc"
RUBY_FAKEGEM_EXTRAINSTALL="support"

inherit ruby-fakegem

DESCRIPTION="Non-interactive SSH processing in pure Ruby"
HOMEPAGE="http://net-ssh.rubyforge.org/"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE=""
