# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/twisted-mail/twisted-mail-8.2.0.ebuild,v 1.3 2009/09/06 20:42:55 idl0r Exp $

MY_PACKAGE=Mail

inherit twisted versionator

DESCRIPTION="A Twisted Mail library, server and client"

KEYWORDS="~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~x86-solaris"

DEPEND="=dev-python/twisted-$(get_version_component_range 1-2)*
	>=dev-python/twisted-names-0.2.0"
RDEPEND="${DEPEND}"

IUSE=""
