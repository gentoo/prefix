# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/rails/rails-2.0.2.ebuild,v 1.7 2008/05/11 17:07:34 fmccor Exp $

EAPI="prefix"

inherit ruby gems

DESCRIPTION="ruby on rails is a web-application and persistance framework"
HOMEPAGE="http://www.rubyonrails.org"

LICENSE="MIT"
SLOT="2"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"

IUSE="fastcgi"
DEPEND=">=dev-lang/ruby-1.8.5
	>=app-admin/eselect-rails-0.11
	>=dev-ruby/rake-0.7.2
	~dev-ruby/activerecord-2.0.2
	~dev-ruby/activeresource-2.0.2
	~dev-ruby/activesupport-2.0.2
	~dev-ruby/actionmailer-2.0.2
	~dev-ruby/actionpack-2.0.2
	!<dev-ruby/rails-1.1.6-r1"

RDEPEND="${DEPEND}
	fastcgi? ( >=dev-ruby/ruby-fcgi-0.8.6 )"

src_install() {
	gems_src_install
	# Rename slotted files that may clash so that eselect can handle
	# them
	mv "${ED}/usr/bin/rails" "${ED}/usr/bin/rails-${PV}"
	mv "${ED}/${GEMSDIR}/bin/rails" "${ED}/${GEMSDIR}/bin/rails-${PV}"
}

pkg_postinst() {
	einfo "To select between slots of rails, use:"
	einfo "\teselect rails"
	# Bring users to rails 2.0.x by default when updating
	eselect rails update 2

	ewarn "All database USE flags have been moved to dev-ruby/activerecord"
}

pkg_postrm() {
	# Drop users back to rails 1.2.x when they remove 2.0.x
	eselect rails update 1.2
}
