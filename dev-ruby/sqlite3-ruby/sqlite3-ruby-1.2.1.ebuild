# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/sqlite3-ruby/sqlite3-ruby-1.2.1.ebuild,v 1.8 2007/05/24 14:05:35 flameeyes Exp $

EAPI="prefix"

inherit ruby

DESCRIPTION="An extension library to access a SQLite database from Ruby"
HOMEPAGE="http://rubyforge.org/projects/sqlite-ruby/"
LICENSE="BSD"

SRC_URI="http://rubyforge.org/frs/download.php/17096/${P}.tar.bz2"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
SLOT="0"
IUSE="doc swig"

USE_RUBY="ruby18 ruby19"
DEPEND="=dev-db/sqlite-3*
	swig? ( dev-lang/swig )"

pkg_setup() {
	if use swig && ! built_with_use dev-lang/swig ruby ; then
		eerror "You must compile swig with ruby bindings. Please add"
		eerror "'ruby' to your USE flags and recompile swig"
		die "swig needs ruby bindings"
	elif ! use swig ; then
		elog "${PN} will work a lot better with swig; it is suggested"
		elog "that you install swig with the 'ruby' USE flag, and then"
		elog "install ${PN} with the swig USE flag"
		ebeep
		epause 5
	fi
}

src_compile() {
	myconf=""
	if ! use swig ; then
		myconf="--without-ext"
	fi

	${RUBY} setup.rb config --prefix="${EPREFIX}"/usr ${myconf} \
		|| die "setup.rb config failed"
	${RUBY} setup.rb setup \
		|| die "setup.rb setup failed"
}

src_install() {
	${RUBY} setup.rb install --prefix=${D} \
		|| die "setup.rb install failed"

	dodoc README ChangeLog
	dohtml doc/faq/faq.html

	if use doc ; then
		dohtml -r -V api
	fi
}
