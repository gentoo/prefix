# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/actionmailer/actionmailer-2.1.2.ebuild,v 1.5 2008/11/06 09:26:11 armin76 Exp $

EAPI="prefix"

inherit ruby gems

DESCRIPTION="Framework for designing email-service layers"
HOMEPAGE="http://rubyforge.org/projects/actionmailer/"

LICENSE="MIT"
SLOT="2.1"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND="=dev-ruby/actionpack-2.1.2
	>=dev-lang/ruby-1.8.5"
