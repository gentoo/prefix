# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/make/make-3.81.ebuild,v 1.13 2008/12/07 03:18:17 vapier Exp $

inherit flag-o-matic

DESCRIPTION="Standard tool to compile source trees"
HOMEPAGE="http://www.gnu.org/software/make/make.html"
SRC_URI="mirror://gnu//make/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls static"

DEPEND="nls? ( sys-devel/gettext )"
RDEPEND="nls? ( virtual/libintl )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-tests-lang.patch
	# https://savannah.gnu.org/bugs/index.php?18680
	epatch "${FILESDIR}"/${P}-eintr-loop.patch

	# breaks build on other interix systems.
	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${P}-interix3.patch

	# this disables make abortion on write errors, which
	# seem to be reported wrongly sporadically on interix.
	epatch "${FILESDIR}"/${P}-interix.patch

	# enable library_search() to look for lib%.dylib on darwin
	epatch "${FILESDIR}"/${P}-darwin-library_search-dylib.patch
}

src_compile() {
	use static && append-ldflags -static
	econf \
		$(use_enable nls) \
		--program-prefix=g \
		|| die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README*
	if [[ ${USERLAND} == "GNU" ]] ; then
		# we install everywhere as 'gmake' but on GNU systems,
		# symlink 'make' to 'gmake'
		dosym gmake /usr/bin/make
		dosym gmake.1 /usr/share/man/man1/make.1
	fi
}
