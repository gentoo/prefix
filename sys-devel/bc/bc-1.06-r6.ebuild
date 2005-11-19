# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/bc/bc-1.06-r6.ebuild,v 1.7 2005/06/28 05:20:06 kumba Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="Handy console-based calculator utility"
HOMEPAGE="http://www.gnu.org/software/bc/bc.html"
SRC_URI="mirror://gnu/bc/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ~ppc-macos ppc64 s390 sh sparc x86"
IUSE="readline static"

RDEPEND="readline? ( >=sys-libs/readline-4.1 >=sys-libs/ncurses-5.2 )"
DEPEND="${RDEPEND}
	sys-devel/flex"

src_unpack() {
	unpack ${A}
	cd ${S}

	epatch ${FILESDIR}/bc-1.06-info-fix.diff
	epatch ${FILESDIR}/bc-1.06-readline42.diff
	epatch ${FILESDIR}/bc-1.06-longopts.patch #51525
	epatch ${FILESDIR}/bc-1.06-static-save.patch
	sed -i -e '/^AR =/s:.*::' lib/Makefile.in

	# Command line arguments for flex changed from the old
	# 2.5.4 to 2.5.22, so fix configure if we are using the
	# new flex.  Note that flex-2.5.4 prints 'flex version 2.5.4'
	# and flex-2.5.22 prints 'flex 2.5.22', bug #10546.
	# <azarah@gentoo.org> (23 Oct 2002)
	local flmajor="`flex --version | cut -d. -f1`"
	local flminor="`flex --version | cut -d. -f2`"
	local flmicro="`flex --version | cut -d. -f3`"
	if [ "${flmajor/flex* }" -ge 2 -a \
	     "${flminor/flex* }" -ge 5 -a \
	     "${flmicro/flex* }" -ge 22 ]
	then
		sed -i -e 's:flex -I8:flex -I:g' \
			configure
	fi
}

src_compile() {
	case ${ARCH} in
		ppc) filter-flags -O2;;
		x86) replace-flags -Os -O2;;
		amd64) replace-flags -O? -O0;;
	esac
	tc-export CC AR RANLIB

	local myconf=""
	use static && append-ldflags -static
	use readline && myconf="--with-readline"
	econf ${myconf} || die
	emake || die
}

src_install() {
	into /usr
	dobin bc/bc dc/dc || die

	doinfo doc/*.info
	doman doc/*.1
	dodoc AUTHORS FAQ NEWS README ChangeLog
}
