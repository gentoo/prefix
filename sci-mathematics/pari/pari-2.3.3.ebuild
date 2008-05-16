# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-mathematics/pari/pari-2.3.3.ebuild,v 1.4 2008/05/14 17:13:39 grozin Exp $

EAPI="prefix"

inherit elisp-common eutils flag-o-matic multilib toolchain-funcs

DESCRIPTION="A software package for computer-aided number theory"
HOMEPAGE="http://pari.math.u-bordeaux.fr/"
SRC_URI="http://pari.math.u-bordeaux.fr/pub/${PN}/unix/${P}.tar.gz
	elliptic? ( http://pari.math.u-bordeaux.fr/pub/${PN}/packages/elldata.tgz )
	galois? ( http://pari.math.u-bordeaux.fr/pub/${PN}/packages/galdata.tgz )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc emacs X elliptic galois gmp static"

DEPEND="doc? ( virtual/tetex )
		sys-libs/readline
		X? ( x11-libs/libX11 )
		emacs? ( virtual/emacs )
		gmp? ( dev-libs/gmp )"

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

	# move data into place
	if ( use galois || use elliptic ); then
		mv "${WORKDIR}"/data "${S}" \
			|| die "failed to move data"
	fi

	epatch "${FILESDIR}/"${PN}-2.3.2-strip.patch
	epatch "${FILESDIR}/"${PN}-2.3.2-ppc-powerpc-arch-fix.patch
	epatch "${FILESDIR}/"${P}-alglin.patch

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

	local myconf="--with-readline"
	use gmp && myconf="${myconf} --kernel=gmp"

	./Configure \
		--prefix="${EPREFIX}"/usr \
		--datadir="${EPREFIX}"/usr/share/${P} \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--mandir="${EPREFIX}"/usr/share/man/man1 \
		${myconf} \
			|| die "./Configure failed"

	if use hppa; then
		mymake=DLLD\="${EPREFIX}"/usr/bin/gcc\ DLLDFLAGS\=-shared\ -Wl,-soname=\$\(LIBPARI_SONAME\)\ -lm
	fi

	local installdir=$(get_compile_dir)
	cd "${installdir}" || die "Bad directory. File a BUG!"

	einfo "Building shared library..."
	emake ${mymake} CFLAGS="${CFLAGS} -DGCC_INLINE -fPIC" lib-dyn \
		|| die "Building shared library failed!"

	if use static; then
		einfo "Building static library..."
		emake ${mymake} CFLAGS="${CFLAGS} -DGCC_INLINE" lib-sta \
			|| die "Building static library failed!"
	fi

	einfo "Building executables..."
	emake ${mymake} CFLAGS="${CFLAGS} -DGCC_INLINE" gp ../gp \
		|| die "Building executables failed!"

	if use doc; then
		cd "${S}"
		# To prevent sandbox violations by metafont
		VARTEXFONTS="${T}"/fonts emake docpdf \
			|| die "Failed to generate docs"
	fi

	if use emacs; then
		cd "${S}/emacs"
		elisp-comp *.el || die "elisp-comp failed"
	fi
}

src_test() {
	make test-kernel
}

src_install() {
	emake DESTDIR="${D}" LIBDIR="${D}${EPREFIX}"/usr/$(get_libdir) install \
		|| die "Install failed"

	if use emacs; then
		elisp-install ${PN} emacs/*.el emacs/*.elc \
			|| die "elisp-install failed"
		elisp-site-file-install "${FILESDIR}/${SITEFILE}"
	fi

	dodoc AUTHORS Announce.2.1 CHANGES README TODO NEW
	if use doc; then
		emake DESTDIR="${D}" LIBDIR="${ED}/usr/$(get_libdir)" install-doc \
			|| die "Failed to install docs"
		insinto /usr/share/doc/${PF}
		doins doc/*.pdf || die "Failed to install pdf docs"
	fi

	if (use galois || use elliptic); then
		emake DESTDIR="${D}" LIBDIR="${D}"/usr/$(get_libdir) install-data \
			|| die "Failed to install data files"
	fi

	if use static; then
		emake DESTDIR="${D}" LIBDIR="${D}"/usr/$(get_libdir) install-lib-sta || \
			die "Install of static library failed"
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
