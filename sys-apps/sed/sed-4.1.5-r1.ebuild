# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/sed/sed-4.1.5-r1.ebuild,v 1.7 2008/06/22 15:26:11 vapier Exp $

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="Super-useful stream editor"
HOMEPAGE="http://sed.sourceforge.net/"
SRC_URI="mirror://gnu/sed/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls static"

RDEPEND="nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_bootstrap_sed() {
	# make sure system-sed works #40786
	export NO_SYS_SED=""
	if ! type -p sed > /dev/null ; then
		NO_SYS_SED="!!!"
		./bootstrap.sh || die "couldnt bootstrap"
		cp sed/sed "${T}"/ || die "couldnt copy"
		export PATH="${PATH}:${T}"
		make clean || die "couldnt clean"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-4.1.4-makeinfo-c-locale.patch
	epatch "${FILESDIR}"/${P}-alloca.patch
	epatch "${FILESDIR}"/${P}-prototypes.patch
	epatch "${FILESDIR}"/${PN}-4.1.4-aix-malloc.patch
	epatch "${FILESDIR}"/${P}-string.patch
	epatch "${FILESDIR}"/${P}-regex-nobool.patch
	epatch "${FILESDIR}"/${P}-irix.patch
	# don't use sed here if we have to recover a broken host sed
}

src_compile() {
	src_bootstrap_sed
	# make sure all sed operations here are repeatable
	sed -i \
		-e '/docdir =/s:=.*/doc:= $(datadir)/doc/'${PF}'/html:' \
		doc/Makefile.in || die "sed html doc"

	local myconf= bindir="${EPREFIX}"/bin
	if ! use userland_GNU ; then
		myconf="--program-prefix=g"
		bindir="${EPREFIX}"/usr/bin
	fi

	if echo "#include <regex.h>" | $(tc-getCPP) > /dev/null ; then
		myconf="${myconf} --without-included-regex"
	fi

	use static && append-ldflags -static
	econf \
		--bindir="${bindir}" \
		$(use_enable nls) \
		${myconf} \
		|| die "Configure failed"
	emake || die "build failed"
}

src_install() {
	emake install DESTDIR="${D}" || die "Install failed"
	dodoc NEWS README* THANKS AUTHORS BUGS ChangeLog
	docinto examples
	dodoc "${FILESDIR}"/{dos2unix,unix2dos}

	rm -f "${ED}"/usr/lib/charset.alias "${ED}"/usr/share/locale/locale.alias
}
