# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/eclass-manpages/eclass-manpages-20070615.ebuild,v 1.3 2007/08/03 08:29:06 zmedico Exp $

EAPI="prefix"

DESCRIPTION="collection of Gentoo eclass manpages"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86 ~x86-fbsd ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND="!app-portage/portage-manpages"

S=${WORKDIR}

src_install() {
	local e
	for e in "${ECLASSDIR}"/*.eclass ; do
		awk -f "${FILESDIR}"/eclass-to-manpage.awk ${e} > ${e##*/}.5 || rm -f ${e##*/}.5
	done
	doman *.5 || die
}
