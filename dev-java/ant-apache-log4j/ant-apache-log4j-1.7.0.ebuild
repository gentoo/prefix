# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-apache-log4j/ant-apache-log4j-1.7.0.ebuild,v 1.10 2007/05/12 17:54:24 wltjr Exp $

EAPI="prefix"

ANT_TASK_DEPNAME="log4j"

inherit ant-tasks

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

DEPEND=">=dev-java/log4j-1.2.13-r2"
RDEPEND="${DEPEND}"
