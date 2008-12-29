# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/nokogiri/nokogiri-1.1.0.ebuild,v 1.3 2008/12/28 02:40:45 flameeyes Exp $

EAPI="prefix"

inherit gems

DESCRIPTION="Nokogiri (驪ｸ) is an HTML, XML, SAX, and Reader parser."
HOMEPAGE="http://nokogiri.rubyforge.org/"
LICENSE="MIT"

KEYWORDS="~amd64-linux ~ppc-macos ~x86-linux ~x86-solaris"
SLOT="0"
IUSE=""

RDEPEND="dev-libs/libxml2
	dev-libs/libxslt"
DEPEND="${RDEPEND}
	>=dev-ruby/hoe-1.7.0"
