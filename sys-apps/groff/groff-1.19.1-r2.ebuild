# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/groff/groff-1.19.1-r2.ebuild,v 1.16 2005/09/29 07:57:59 usata Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs

MB_PATCH="groff_1.18.1-7" #"${P/-/_}-7"
DESCRIPTION="Text formatter used for man pages"
HOMEPAGE="http://www.gnu.org/software/groff/groff.html"
SRC_URI="mirror://gnu/groff/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ~ppc-macos ppc64 s390 sh sparc x86"
IUSE="X"

DEPEND=">=sys-apps/texinfo-4.7-r1
	!app-i18n/man-pages-ja"
PDEPEND=">=sys-apps/man-1.5k-r1"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix the info pages to have .info extensions,
	# else they do not get gzipped.
	epatch "${FILESDIR}"/groff-1.18-infoext.patch

	# Do not generate example files that require us to
	# depend on netpbm.
	epatch "${FILESDIR}"/groff-1.18-no-netpbm-depend.patch

	# Make dashes the same as minus on the keyboard so that you
	# can search for it. Fixes #17580 and #16108
	# Thanks to James Cloos <cloos@jhcloos.com>
	epatch "${FILESDIR}"/${PN}-man-UTF-8.diff

	# Fix stack limit (inifite loop) #64117
	epatch "${FILESDIR}"/${P}-stack.patch

	# Fix tempfile usage #68404
	epatch "${FILESDIR}"/${P}-tmpfile.patch

	# Fix make dependencies so we can build in parallel
	epatch "${FILESDIR}"/${P}-parallel-make.patch

	# Make sure we can cross-compile this puppy
	if tc-is-cross-compiler ; then
		sed -i \
			-e '/^GROFFBIN=/s:=.*:=/usr/bin/groff:' \
			-e '/^TROFFBIN=/s:=.*:=/usr/bin/troff:' \
			-e '/^GROFF_BIN_PATH=/s:=.*:=:' \
			contrib/mom/Makefile.sub \
			doc/Makefile.in \
			doc/Makefile.sub || die "cross-compile sed failed"
		touch .dont-build-X
	fi
	# Only build X stuff if we have X installed, but do 
	# not depend on it, else we get circular deps :(
	if ! use X || [[ -z $(type -p xmkmf) ]] ; then
		touch .dont-build-X
	fi
}

src_compile() {
	# Fix problems with not finding g++
	tc-export CC CXX

	# -Os causes segfaults, -O is probably a fine replacement
	# (fixes bug 36008, 06 Jan 2004 agriffis)
	replace-flags -Os -O

	# -march=2.0 makes groff unable to finish the compile process
	use hppa && replace-cpu-flags 2.0 1.0

	# CJK doesnt work yet with groff-1.19
	#	$(use_enable cjk multibyte)

	# many fun sandbox errors with econf
	./configure \
		--host=${CHOST} \
		--prefix=${PREFIX}/usr \
		--mandir=${PREFIX}/usr/share/man \
		--infodir=\${inforoot} \
		|| die
	emake || die

	if [ ! -f .dont-build-X ] ; then
		cd ${S}/src/xditview
		xmkmf || die
		make depend all || die
	fi
}

src_install() {
	dodir /usr /usr/share/doc/${PF}/{examples,html}
	make \
		prefix="${D}"/usr \
		manroot="${D}"/usr/share/man \
		inforoot="${D}"/usr/share/info \
		docdir="${D}"/usr/share/doc/${PF} \
		install || die

	# The following links are required for xman
	dosym eqn /usr/bin/geqn
	dosym tbl /usr/bin/gtbl
	dosym soelim /usr/bin/zsoelim

	dodoc BUG-REPORT ChangeLog FDL MORE.STUFF NEWS \
		PROBLEMS PROJECTS README REVISION TODO VERSION

	if [ ! -f .dont-build-X ] ; then
		cd ${S}/src/xditview
		make DESTDIR="${D}" \
			BINDIR=/usr/bin \
			MANPATH=/usr/share/man \
			install \
			install.man || die
	fi
}
