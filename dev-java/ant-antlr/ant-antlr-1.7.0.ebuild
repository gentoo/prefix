# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-antlr/ant-antlr-1.7.0.ebuild,v 1.14 2009/03/24 19:45:35 betelgeuse Exp $

EAPI=1

inherit java-pkg-2 ant-tasks

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

DEPEND=">=dev-java/antlr-2.7.5-r3:0"
RDEPEND="${DEPEND}"

pkg_setup() {
	if ! built_with_use dev-java/antlr:0 java; then
		msg="dev-java/antlr needs to be built with the java use flag"
		eerror ${msg}
		die ${msg}
	fi
	java-pkg-2_pkg_setup
}
