# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-antlr/ant-antlr-1.7.1.ebuild,v 1.2 2008/07/14 23:02:02 mr_bones_ Exp $

EAPI="prefix 1"

# just a runtime dependency
ANT_TASK_DEPNAME=""

inherit ant-tasks

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

DEPEND=""
RDEPEND=">=dev-java/antlr-2.7.5-r3:0"

src_install() {
	ant-tasks_src_install
	java-pkg_register-dependency antlr
}
