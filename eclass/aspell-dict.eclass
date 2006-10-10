# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/aspell-dict.eclass,v 1.37 2006/06/05 03:27:20 vapier Exp $
#
# Author: Seemant Kulleen <seemant@gentoo.org>
#
# The aspell-dict eclass is designed to streamline the construction of
# ebuilds for the new aspell dictionaries (from gnu.org) which support
# aspell-0.50. Support for aspell-0.60 has been added by Sergey Ulanov.


EXPORT_FUNCTIONS src_compile src_install

#MY_P=${PN}-${PV%.*}-${PV#*.*.}
MY_P=${P%.*}-${PV##*.}
MY_P=aspell${ASPOSTFIX}-${MY_P/aspell-/}
SPELLANG=${PN/aspell-/}
S=${WORKDIR}/${MY_P}
DESCRIPTION="${ASPELL_LANG} language dictionary for aspell"
HOMEPAGE="http://aspell.net"
SRC_URI="ftp://ftp.gnu.org/gnu/aspell/dict/${SPELLANG}/${MY_P}.tar.bz2"

IUSE=""
SLOT="0"

if [ x${ASPOSTFIX} = x6 ] ; then
	RDEPEND=">=app-text/aspell-0.60"
	DEPEND="${RDEPEND}"
	KEYWORDS="~amd64 ~ppc ~sparc ~x86 ~x86-fbsd"
else
	RDEPEND=">=app-text/aspell-0.50"
	DEPEND="${RDEPEND}"
	KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
fi

PROVIDE="virtual/aspell-dict"

aspell-dict_src_compile() {
	./configure || die
	emake || die
}

aspell-dict_src_install() {
	make DESTDIR="${D}" install || die

	for doc in README info ; do
		[ -s "$doc" ] && dodoc $doc
	done
}
