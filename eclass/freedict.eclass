# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/freedict.eclass,v 1.15 2006/06/22 21:17:49 gustavoz Exp $

# Author: Seemant Kulleen <seemant@gentoo.org>
# This eclass exists to ease the installation of freedict translation
# dictionaries.  The only variables which need to be defined in the actual
# ebuilds are FORLANG and TOLANG for the source and target languages,
# respectively.

inherit eutils

IUSE=""

MY_P=${PN/freedict-/}

S=${WORKDIR}
DESCRIPTION="Freedict for language translation from ${FORLANG} to ${TOLANG}"
HOMEPAGE="http://www.freedict.de"
SRC_URI="http://freedict.sourceforge.net/download/linux/${MY_P}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="x86 ~amd64 ppc sparc alpha ~mips ~hppa"

DEPEND="app-text/dictd"

freedict_src_install() {
	insinto /usr/$(get_libdir)/dict
	doins ${MY_P}.dict.dz
	doins ${MY_P}.index
}

EXPORT_FUNCTIONS src_install
