# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-antlr/ant-antlr-1.7.0.ebuild,v 1.10 2007/05/12 17:46:35 wltjr Exp $

EAPI="prefix"

inherit ant-tasks

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-fbsd ~x86-macos"

DEPEND=">=dev-java/antlr-2.7.5-r3"
RDEPEND="${DEPEND}"
