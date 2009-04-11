# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-antlr/ant-antlr-1.7.1.ebuild,v 1.8 2009/01/03 15:55:36 armin76 Exp $

EAPI=1

# just a runtime dependency
ANT_TASK_DEPNAME=""

inherit ant-tasks

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

DEPEND=""
RDEPEND=">=dev-java/antlr-2.7.5-r3:0"

src_install() {
	ant-tasks_src_install
	java-pkg_register-dependency antlr
}
