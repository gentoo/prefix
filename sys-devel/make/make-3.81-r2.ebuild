# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/make/make-3.81-r2.ebuild,v 1.10 2012/05/24 02:38:35 vapier Exp $

inherit flag-o-matic eutils

DESCRIPTION="Standard tool to compile source trees"
HOMEPAGE="http://www.gnu.org/software/make/make.html"
SRC_URI="mirror://gnu//make/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls static"

DEPEND="nls? ( sys-devel/gettext )"
RDEPEND="nls? ( virtual/libintl )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-tests-lang.patch
	epatch "${FILESDIR}"/${P}-long-cmdline.patch #301116
	epatch "${FILESDIR}"/${P}-tests-recursion.patch #329153
	epatch "${FILESDIR}"/${P}-jobserver.patch #193258
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
	local myconf=
	use static && append-ldflags -static

	if [[ ${CHOST} == *-interix* ]]; then
		# on interix, many others don't know large files (coreutils...),
		# so no need for make to build that code.
		myconf="${myconf} --disable-largefile"

		# job-server does more harm than it helps. building with multiple
		# jobs is still possible, but only local in one dir (which is the
		# case with autotools anyway)
		myconf="${myconf} --disable-job-server"

		# on windows, the file system is case insensitive, so this would be
		# correct, BUT: the APIs provided by SUA talk to the NT kernel, and
		# there, objects are case sensitive, which makes the filesystem from
		# a programmers POV case sensitive... :/
		# myconf="${myconf} --enable-case-insensitive-file-system"
	fi

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
