# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-apache-oro/ant-apache-oro-1.7.0.ebuild,v 1.10 2007/05/12 17:57:26 wltjr Exp $

EAPI="prefix"

ANT_TASK_DEPNAME="jakarta-oro-2.0"

inherit ant-tasks

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-fbsd ~x86-macos"

DEPEND=">=dev-java/jakarta-oro-2.0.8-r2"
RDEPEND="${DEPEND}"
