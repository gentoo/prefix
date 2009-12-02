# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/twisted-mail/twisted-mail-9.0.0.ebuild,v 1.1 2009/11/30 01:32:02 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"
MY_PACKAGE="Mail"

inherit twisted versionator

DESCRIPTION="A Twisted Mail library, server and client"

KEYWORDS="~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="=dev-python/twisted-$(get_version_component_range 1-2)*
	>=dev-python/twisted-names-0.2.0"
RDEPEND="${DEPEND}"
RESTRICT_PYTHON_ABIS="3.*"

PYTHON_MODNAME="twisted/mail twisted/plugins"
