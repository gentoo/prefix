# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-javamail/ant-javamail-1.7.1.ebuild,v 1.1 2008/07/14 21:57:09 caster Exp $

EAPI="prefix 1"

ANT_TASK_DEPNAME="--virtual javamail"

inherit ant-tasks

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"

DEPEND="java-virtuals/javamail
	dev-java/sun-jaf"
RDEPEND="${DEPEND}"

src_unpack() {
	ant-tasks_src_unpack all
	java-pkg_jar-from sun-jaf
}
