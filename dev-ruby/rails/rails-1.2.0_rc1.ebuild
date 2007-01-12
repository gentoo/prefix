# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/rails/rails-1.2.0_rc1.ebuild,v 1.1 2006/11/24 01:29:06 caleb Exp $

EAPI="prefix"

inherit ruby gems

MY_P="${PN}-1.1.6.5618"

USE_RUBY="ruby18"
DESCRIPTION="ruby on rails is a web-application and persistance framework"
HOMEPAGE="http://www.rubyonrails.org"
# The URL depends implicitly on the version, unfortunately. Even if you
# change the filename on the end, it still downloads the same file.
SRC_URI="http://gems.rubyonrails.org/gems/${MY_P}.gem"

LICENSE="Ruby"
SLOT="1.2"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"

S=${WORKDIR}/${MY_P}

IUSE="mysql sqlite sqlite3 postgres fastcgi"
DEPEND=">=dev-lang/ruby-1.8.5
	>=dev-ruby/rake-0.7.1
	=dev-ruby/activerecord-1.14.4.5618
	=dev-ruby/actionmailer-1.2.5.5618
	=dev-ruby/actionwebservice-1.1.6.5618
	fastcgi? ( >=dev-ruby/ruby-fcgi-0.8.6 )
	sqlite? ( >=dev-ruby/sqlite-ruby-2.2.2 )
	sqlite3? ( dev-ruby/sqlite3-ruby )
	mysql? ( >=dev-ruby/mysql-ruby-2.7 )
	postgres? ( >=dev-ruby/ruby-postgres-0.7.1 )"
