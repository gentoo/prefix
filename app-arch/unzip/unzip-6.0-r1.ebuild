# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/unzip/unzip-6.0-r1.ebuild,v 1.12 2010/08/02 20:31:44 jer Exp $

inherit eutils toolchain-funcs flag-o-matic

MY_P="${PN}${PV/.}"

DESCRIPTION="unzipper for pkzip-compressed files"
HOMEPAGE="http://www.info-zip.org/"
SRC_URI="mirror://sourceforge/infozip/${MY_P}.tar.gz"

LICENSE="Info-ZIP"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="bzip2 unicode"

DEPEND="bzip2? ( app-arch/bzip2 )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-no-exec-stack.patch
	epatch "${FILESDIR}"/${P}-irix.patch
	sed -i \
		-e '/^CFLAGS/d' \
		-e '/CFLAGS/s:-O[0-9]\?:$(CFLAGS) $(CPPFLAGS):' \
		-e '/^STRIP/s:=.*:=true:' \
		-e "s:\<CC=gcc\>:CC=$(tc-getCC):" \
		-e "s:\<LD=gcc\>:LD=$(tc-getCC):" \
		-e "s:\<AS=gcc\>:AS=$(tc-getCC):" \
		-e 's:LF2 = -s:LF2 = :' \
		-e 's:LF = :LF = $(LDFLAGS) :' \
		-e 's:SL = :SL = $(LDFLAGS) :' \
		-e 's:FL = :FL = $(LDFLAGS) :' \
		-e "/^#L_BZ2/s:^$(use bzip2 && echo .)::" \
		-e 's:STRIP =.*$:STRIP = true:' \
		-e "s!CF = \$(CFLAGS) \$(CF_NOOPT)!CF = \$(CFLAGS) \$(CF_NOOPT) \$(CPPFLAGS)!" \
		unix/Makefile \
		|| die "sed unix/Makefile failed"
}

src_compile() {
	local TARGET
	case ${CHOST} in
		i?86*-*linux*)       TARGET=linux_asm ;;
		*linux*)             TARGET=linux_noasm ;;
		i?86*-*bsd* | \
		i?86*-dragonfly*)    TARGET=freebsd ;; # mislabelled bsd with x86 asm
		*bsd* | *dragonfly*) TARGET=bsd ;;
		*-darwin*)           TARGET=macosx; append-cppflags "-DNO_LCHMOD" ;;
		*-solaris*)          TARGET=generic ;;
		mips-sgi-irix*)      TARGET=sgi; append-cppflags "-DNO_LCHMOD" ;;
		*-interix3*)         TARGET=gcc; append-flags "-DUNIX"; append-cppflags "-DNO_LCHMOD" ;;
		*-interix*)          TARGET=gcc; append-flags "-DUNIX -DNO_LCHMOD" ;;
		*-aix*)              TARGET=gcc; append-cppflags "-DNO_LCHMOD"; append-ldflags "-Wl,-blibpath:${EPREFIX}/usr/$(get_libdir)" ;;
		*-hpux*)             TARGET=gcc; append-ldflags "-Wl,+b,${EPREFIX}/usr/$(get_libdir)" ;;
		*-mint*)             TARGET=generic ;;
		*) die "Unknown target, you suck" ;;
	esac

	[[ ${CHOST} == *linux* ]] && append-cppflags -DNO_LCHMOD
	use bzip2 && append-cppflags -DUSE_BZIP2
	use unicode && append-cppflags -DUNICODE_SUPPORT -DUNICODE_WCHAR -DUTF8_MAYBE_NATIVE
	append-cppflags -DLARGE_FILE_SUPPORT #281473

	emake \
		-f unix/Makefile \
		${TARGET} || die "emake failed"
}

src_install() {
	dobin unzip funzip unzipsfx unix/zipgrep || die "dobin failed"
	dosym unzip /usr/bin/zipinfo || die
	doman man/*.1
	dodoc BUGS History* README ToDo WHERE
}
