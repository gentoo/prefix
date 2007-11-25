# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-commons-net/ant-commons-net-1.7.0.ebuild,v 1.10 2007/05/12 18:10:28 wltjr Exp $

EAPI="prefix"

inherit ant-tasks

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"

DEPEND=">=dev-java/commons-net-1.4.1-r1"
RDEPEND="${DEPEND}"
