# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/rails/rails-2.3.2.ebuild,v 1.6 2009/05/24 18:56:08 maekke Exp $

inherit ruby gems
USE_RUBY="ruby18 ruby19"

DESCRIPTION="ruby on rails is a web-application and persistance framework"
HOMEPAGE="http://www.rubyonrails.org"

LICENSE="MIT"
SLOT="2.3"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"

IUSE="fastcgi"
DEPEND=">=dev-lang/ruby-1.8.6
	>=app-admin/eselect-rails-0.15
	>=dev-ruby/rake-0.8.3
	~dev-ruby/activerecord-2.3.2
	~dev-ruby/activeresource-2.3.2
	~dev-ruby/activesupport-2.3.2
	~dev-ruby/actionmailer-2.3.2
	~dev-ruby/actionpack-2.3.2"

RDEPEND="${DEPEND}
	fastcgi? ( >=dev-ruby/ruby-fcgi-0.8.6 )
	>=dev-ruby/rubygems-1.3.1"

src_install() {
	gems_src_install
	# Rename slotted files that may clash so that eselect can handle
	# them
	mv "${ED}/usr/bin/rails" "${ED}/usr/bin/rails-${PV}"
	sed -i -e "s/>= 0/${PV}/" "${ED}/usr/bin/rails-${PV}"
	mv "${ED}/${GEMSDIR}/bin/rails" "${ED}/${GEMSDIR}/bin/rails-${PV}"
}

pkg_postinst() {
	einfo "To select between slots of rails, use:"
	einfo "\teselect rails"

	eselect rails update
}

pkg_postrm() {
	eselect rails update
}
