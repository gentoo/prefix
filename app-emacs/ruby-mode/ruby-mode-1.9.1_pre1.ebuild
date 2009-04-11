# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/ruby-mode/ruby-mode-1.9.1_pre1.ebuild,v 1.1 2008/11/02 02:07:07 flameeyes Exp $

inherit elisp

MY_PV=${PV/_pre/-preview}

DESCRIPTION="Emacs major mode for editing Ruby code"
HOMEPAGE="http://www.ruby-lang.org/"
SRC_URI="mirror://ruby/ruby-${MY_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

SITEFILE=50${PN}-gentoo.el
S="${WORKDIR}/ruby-${MY_PV}/misc"
