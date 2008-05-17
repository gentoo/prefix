# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/rails/rails-1.2.5.ebuild,v 1.6 2007/10/21 15:24:43 beandog Exp $

EAPI="prefix"

inherit ruby gems

DESCRIPTION="ruby on rails is a web-application and persistance framework"
HOMEPAGE="http://www.rubyonrails.org"

LICENSE="MIT"
SLOT="1.2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"

IUSE="mysql sqlite sqlite3 postgres fastcgi"
DEPEND=">=dev-lang/ruby-1.8.5
	app-admin/eselect-rails
	>=dev-ruby/rake-0.7.2
	=dev-ruby/activerecord-1.15.5
	=dev-ruby/actionmailer-1.3.5
	=dev-ruby/actionwebservice-1.2.5
	=dev-ruby/activesupport-1.4.4
	=dev-ruby/actionpack-1.13.5
	!<dev-ruby/rails-1.1.6-r1"

RDEPEND="${DEPEND}
	fastcgi? ( >=dev-ruby/ruby-fcgi-0.8.6 )
	sqlite? ( >=dev-ruby/sqlite-ruby-2.2.2 )
	sqlite3? ( dev-ruby/sqlite3-ruby )
	mysql? ( >=dev-ruby/mysql-ruby-2.7 )
	postgres? ( >=dev-ruby/ruby-postgres-0.7.1 )"

src_install() {
	gems_src_install
	# Rename slotted files that may clash so that eselect can handle
	# them
	mv ${ED}/usr/bin/rails ${ED}/usr/bin/rails-${PV}
	mv ${ED}/${GEMSDIR}/bin/rails ${ED}/${GEMSDIR}/bin/rails-${PV}
}

pkg_postinst() {
	einfo "To select between slots of rails, use:"
	einfo "\teselect rails"
	eselect rails update --if-unset
}

pkg_postrm() {
	eselect rails update --if-unset
}
