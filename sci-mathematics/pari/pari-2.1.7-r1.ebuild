# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-mathematics/pari/pari-2.1.7-r1.ebuild,v 1.13 2010/05/05 16:07:24 bicatali Exp $

inherit eutils toolchain-funcs flag-o-matic prefix

DESCRIPTION="pari (or pari-gp) : a software package for computer-aided number theory"
HOMEPAGE="http://pari.math.u-bordeaux.fr/"
SRC_URI="http://pari.math.u-bordeaux.fr/pub/pari/unix/OLD/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="doc emacs"

DEPEND="doc? ( virtual/latex-base )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/docs.patch

	# remove exec stacks for x86; see bug #117434
	epatch "${FILESDIR}"/pari-non-exec-stack-x86-gentoo.patch

	epatch "${FILESDIR}"/pari-2.1.7-darwin.patch
	epatch "${FILESDIR}"/pari-2.1.7-prefix.patch
	eprefixify Configure
}

src_compile() {
	# Fix usage of toolchain
	tc-getAS; tc-getLD; tc-getCC; tc-getCXX

	# Special handling for sparc
	local myhost
	[ "${PROFILE_ARCH}" == "sparc64" ] && myhost="sparc64-linux" \
		|| myhost="$(echo ${CHOST} | cut -f "1 3" -d '-')"
	einfo "Building for ${myhost}"

	# need to force optimization here, as it breaks without
	if   is-flag -O0; then
		replace-flags -O0 -O2
	elif ! is-flag -O?; then
		append-flags -O2
	fi

	# fix up build scripts to get rid of insecure RUNPATHS
	# see bug #117434
	sed -e "s|\$runpathprefix \$TOP/\$objdir:\$tmp||" \
		-e "s|\$runpathprefix \$tmp||" -i config/Makefile.SH || \
		die "Failed to fix Makefile.SH"
	sed -e "s|-L\$libdir|-L./|" -i Configure || \
		die "Failed to fix Configure"

	local myconf
	[[ ${CHOST} == *86-*-darwin* ]] && myconf=--disable-kernel

	./Configure \
		${myconf} \
		--host=${myhost} \
		--prefix="${EPREFIX}"/usr \
		--miscdir="${EPREFIX}"/usr/share/doc/${PF} \
		--datadir="${EPREFIX}"/usr/share/${P} \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--mandir="${EPREFIX}"/usr/share/man/man1 || die "./configure failed"
	addwrite "/var/lib/texmf"
	addwrite "/usr/share/texmf"
	addwrite "/var/cache/fonts"

	if use hppa
	then
		mymake=DLLD\=/usr/bin/gcc\ DLLDFLAGS\=-shared\ -Wl,-soname=\$\(LIBPARI_SONAME\)\ -lm
	fi

	# Shared libraries should be PIC on ALL architectures.
	# Danny van Dyk <kugelfang@gentoo.org> 2005/03/31
	# Fixes BUG #49583
	einfo "Building shared library..."
	cd O*-* || die "Bad directory. File a BUG!"
	emake ${mymake} CFLAGS="${CFLAGS} -DGCC_INLINE -fPIC" lib-dyn || die "Building shared library failed!"

	einfo "Building executables..."
	emake ${mymake} CFLAGS="${CFLAGS} -DGCC_INLINE" gp ../gp || die "Building executables failed!"

	use doc || rm -rf doc/*.tex
	use doc && emake doc
}

src_test() {
	ebegin "Testing pari kernel"
	make CFLAGS="-Wl,-lpari" test-kernel > /dev/null
	eend $?
}

src_install() {
	make DESTDIR="${D}" LIBDIR="${ED}"/usr/$(get_libdir) install || die
	if use emacs; then
		insinto /usr/share/emacs/site-lisp
		doins emacs/pari.el
		fi
	dodoc AUTHORS Announce.2.1 CHANGES README TODO
}
