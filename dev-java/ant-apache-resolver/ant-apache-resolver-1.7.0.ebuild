# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-apache-resolver/ant-apache-resolver-1.7.0.ebuild,v 1.10 2007/05/12 18:07:57 wltjr Exp $

EAPI="prefix"

ANT_TASK_DEPNAME="xml-commons-resolver"

inherit ant-tasks

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

DEPEND=">=dev-java/xml-commons-resolver-1.1-r1"
RDEPEND="${DEPEND}"
