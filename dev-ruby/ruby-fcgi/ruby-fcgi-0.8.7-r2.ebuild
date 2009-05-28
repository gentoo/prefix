# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/ruby-fcgi/ruby-fcgi-0.8.7-r2.ebuild,v 1.1 2009/05/27 17:04:12 flameeyes Exp $

inherit ruby

DESCRIPTION="FastCGI library for Ruby"
HOMEPAGE="http://rubyforge.org/projects/fcgi/"
SRC_URI="mirror://rubyforge/fcgi/${P}.tar.gz"

KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
LICENSE="Ruby"

DEPEND="dev-libs/fcgi"
RDEPEND="${DEPEND}"

IUSE=""

USE_RUBY="ruby18 ruby19"
PATCHES=( "${FILESDIR}/${P}-19compat.patch" )

# Use a custom src_install instead of the default one in ruby.eclass
# because the one in ruby.eclass does not include setting the prefix
# for the installation step.

src_compile() {
	# If it's not 1.8 we have no business here at all!
	${RUBY} --version | fgrep -q 'ruby 1.8' || \
		return 0

	ruby_src_compile
}

src_install() {
	if ${RUBY} --version | fgrep -q 'ruby 1.8'; then
		${RUBY} install.rb install --prefix="${D}" \
			|| die "install.rb install failed"
	else
		 # Just install the fcgi.rb file, easier than trying to get to
		 # reason with the install.rb script.
		doruby lib/fcgi.rb || die
	fi

	cd "${S}"
	dodoc ChangeLog README README.signals || die
}
