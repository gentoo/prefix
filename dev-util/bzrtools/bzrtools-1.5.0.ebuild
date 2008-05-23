# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/bzrtools/bzrtools-1.5.0.ebuild,v 1.1 2008/05/22 16:46:49 hawking Exp $

EAPI="prefix"

NEED_PYTHON=2.4

inherit distutils versionator

DESCRIPTION="bzrtools is a useful collection of utilities for bzr."
HOMEPAGE="http://bazaar.canonical.com/BzrTools"
SRC_URI="http://launchpad.net/bzrtools/stable/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="=dev-util/bzr-$(get_version_component_range 1-2)*"

DOCS="CREDITS NEWS.Shelf TODO.Shelf"

S="${WORKDIR}/${PN}"

PYTHON_MODNAME=bzrlib
