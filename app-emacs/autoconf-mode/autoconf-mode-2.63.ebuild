# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/autoconf-mode/autoconf-mode-2.63.ebuild,v 1.1 2008/10/13 10:21:21 ulm Exp $

EAPI="prefix"

inherit elisp

DESCRIPTION="Emacs major modes for editing autoconf and autotest input"
HOMEPAGE="http://www.gnu.org/software/autoconf/autoconf.html"
SRC_URI="mirror://gnu/autoconf/autoconf-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
IUSE=""

SITEFILE=50${PN}-gentoo.el
S="${WORKDIR}/autoconf-${PV}/lib/emacs"
