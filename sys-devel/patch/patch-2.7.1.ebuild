# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/patch/patch-2.7.1.ebuild,v 1.1 2012/09/28 22:16:50 vapier Exp $

inherit flag-o-matic unpacker

DESCRIPTION="Utility to apply diffs to files"
HOMEPAGE="http://www.gnu.org/software/patch/patch.html"
SRC_URI="mirror://gnu/patch/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="static test xattr"

RDEPEND="xattr? ( sys-apps/attr )"
DEPEND="${RDEPEND}
	test? ( sys-apps/ed )"

src_compile() {
	use static && append-ldflags -static

	local myconf=""
	[[ ${USERLAND} == "BSD" ]] && use !prefix && myconf="--program-prefix=g"
	econf \
		$(use_enable xattr) \
		${myconf}

	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README
}
