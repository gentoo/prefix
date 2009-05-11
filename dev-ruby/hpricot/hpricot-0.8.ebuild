# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/hpricot/hpricot-0.8.ebuild,v 1.2 2009/05/09 12:24:23 flameeyes Exp $

EAPI=2

inherit ruby

GITHUB_USER=why

USE_RUBY="ruby18"

DESCRIPTION="A fast and liberal HTML parser for Ruby."
HOMEPAGE="http://wiki.github.com/why/hpricot"

SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="doc test"

DEPEND="dev-util/ragel
	dev-ruby/rake"
RDEPEND=">=dev-lang/ruby-1.8.4"

dofakegemspec() {
	cat - > "${T}"/${P}.gemspec <<EOF
Gem::Specification.new do |s|
  s.name = "${PN}"
  s.version = "${PV}"
  s.summary = "${DESCRIPTION}"
  s.homepage = "${HOMEPAGE}"
end
EOF

	insinto $(${RUBY} -r rbconfig -e 'print Config::CONFIG["vendorlibdir"]' | sed -e 's:vendor_ruby:gems:')/specifications
	doins "${T}"/${P}.gemspec || die "Unable to install fake gemspec"
}

src_compile() {
	rake compile || die "rake failed"

	if use doc; then
		rake rdoc || die "rake rdoc failed"
	fi
}

src_test() {
	for ruby in $USE_RUBY; do
		[[ -n `type -p $ruby` ]] || continue
		$ruby $(type -p rake) test || die "testsuite failed"
	done
}

src_install() {
	pushd lib
	doruby -r *.rb hpricot || die "doruby failed"
	exeinto $(${RUBY} -r rbconfig -e 'print Config::CONFIG["sitearchdir"]')
	doexe *.so || die "doruby failed"
	popd

	if use doc; then
		dohtml -r doc/* || die "dohtml failed"
	fi

	dodoc CHANGELOG README || die "dodoc failed"

	dofakegemspec
}
