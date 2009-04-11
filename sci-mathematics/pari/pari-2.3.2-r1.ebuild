# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-mathematics/pari/pari-2.3.2-r1.ebuild,v 1.13 2008/08/27 20:04:42 markusle Exp $

inherit elisp-common eutils flag-o-matic multilib toolchain-funcs

DESCRIPTION="A software package for computer-aided number theory"
HOMEPAGE="http://pari.math.u-bordeaux.fr/"
SRC_URI="http://pari.math.u-bordeaux.fr/pub/pari/unix/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc emacs X"

DEPEND="doc? ( virtual/latex-base )
		sys-libs/readline
		X? ( x11-libs/libX11 )
		emacs? ( virtual/emacs )"
SITEFILE=50${PN}-gentoo.el

get_compile_dir() {
	pushd "${S}/config" >& /dev/null
	local fastread=yes
	source ./get_archos
	popd >& /dev/null
	echo "O${osname}-${arch}"
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/"${P}-strip.patch
	epatch "${FILESDIR}/"${P}-ppc-powerpc-arch-fix.patch

	# disable default building of docs during install
	sed -e "s:install-doc install-examples:install-examples:" \
		-i config/Makefile.SH || die "Failed to fix makefile"
}

src_compile() {
	#need to force optimization here, as it breaks without
	if   is-flag -O0; then
		replace-flags -O0 -O2
	elif ! is-flag -O?; then
		append-flags -O2
	fi

	./Configure \
		--prefix="${EPREFIX}"/usr \
		--datadir="${EPREFIX}"/usr/share/${P} \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--mandir="${EPREFIX}"/usr/share/man/man1 || die "./Configure failed"

	if use hppa; then
		mymake=DLLD\=/usr/bin/gcc\ DLLDFLAGS\=-shared\ -Wl,-soname=\$\(LIBPARI_SONAME\)\ -lm
	fi

	# Shared libraries should be PIC on ALL architectures.
	# Danny van Dyk <kugelfang@gentoo.org> 2005/03/31
	# Fixes BUG #49583
	local installdir=$(get_compile_dir)
	einfo "Building shared library..."
	cd "${installdir}" || die "Bad directory. File a BUG!"
	emake ${mymake} CFLAGS="${CFLAGS} -DGCC_INLINE -fPIC" lib-dyn || die "Building shared library failed!"

	einfo "Building executables..."
	emake ${mymake} CFLAGS="${CFLAGS} -DGCC_INLINE" gp ../gp || die "Building executables failed!"

	if use doc; then
		cd "${S}"
		emake docpdf || die "Failed to generate docs"
	fi

	if use emacs; then
		cd "${S}/emacs"
		elisp-compile *.el || die "elisp-compile failed"
	fi
}

src_test() {
	make test-kernel
}

src_install() {
	emake DESTDIR="${D}" LIBDIR="${ED}"/usr/$(get_libdir) install || \
		die "Install failed"

	if use emacs; then
		elisp-install ${PN} emacs/*.el emacs/*.elc || die "elisp-install failed"
		elisp-site-file-install "${FILESDIR}/${SITEFILE}"
	fi

	dodoc AUTHORS Announce.2.1 CHANGES README TODO NEW
	if use doc; then
		emake DESTDIR="${D}" LIBDIR="${ED}/usr/$(get_libdir)" install-doc \
			|| die "Failed to install docs"
		insinto /usr/share/doc/${PF}
		doins doc/*.pdf || die "Failed to install pdf docs"
	fi

	#remove superfluous doc directory
	rm -fr "${ED}/usr/share/${P}/doc" || \
		die "Failed to clean up doc directory"
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
