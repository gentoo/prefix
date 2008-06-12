# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-jdepend/ant-jdepend-1.7.0.ebuild,v 1.10 2007/05/12 18:12:57 wltjr Exp $

EAPI="prefix"

inherit ant-tasks

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

DEPEND=">=dev-java/jdepend-2.9-r2"
RDEPEND="${DEPEND}"
