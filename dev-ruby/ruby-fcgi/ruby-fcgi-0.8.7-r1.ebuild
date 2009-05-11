# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/ruby-fcgi/ruby-fcgi-0.8.7-r1.ebuild,v 1.1 2009/05/10 19:27:23 a3li Exp $

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

src_install() {
	RUBY_ECONF="${RUBY_ECONF} ${EXTRA_ECONF}"

	${RUBY} install.rb install --prefix="${D}" "$@" \
		${RUBY_ECONF} || die "install.rb install failed"

	cd "${S}"
	dodoc ChangeLog README README.signals
}
