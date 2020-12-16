# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic multilib-minimal

DESCRIPTION="General purpose crypto library based on the code used in GnuPG"
HOMEPAGE="http://www.gnupg.org/"
SRC_URI="mirror://gnupg/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1 MIT"
SLOT="0/20" # subslot = soname major version
KEYWORDS="~x64-cygwin ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc o-flag-munging static-libs"

RDEPEND=">=dev-libs/libgpg-error-1.25[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}"
BDEPEND="doc? ( virtual/texi2dvi )"

PATCHES=(
	"${FILESDIR}"/${PN}-1.6.1-uscore.patch
	"${FILESDIR}"/${PN}-multilib-syspath.patch
)

MULTILIB_CHOST_TOOLS=(
	/usr/bin/libgcrypt-config
)

src_prepare() {
	default
	# missing attribute(sysv_abi) for Cygwin?
	[[ ${CHOST} == *-cygwin* ]] && rm -f mpi/*/*.S
	# always use -no-undefined even if upstream is not convinced yet
	sed -i -e 's/^no_undefined\s*=\s*$/& -no-undefined/' src/Makefile.am || die
	eautoreconf
}

multilib_src_configure() {
	if [[ ${CHOST} == *86*-solaris* ]] ; then
		# ASM code uses GNU ELF syntax, divide in particular, we need to
		# allow this via ASFLAGS, since we don't have a flag-o-matic
		# function for that, we'll have to abuse cflags for this
		append-cflags -Wa,--divide
	fi
	local myeconfargs=(
		--enable-noexecstack
		$(use_enable o-flag-munging O-flag-munging)
		$(use_enable static-libs static)

		# disabled due to various applications requiring privileges
		# after libgcrypt drops them (bug #468616)
		--without-capabilities

		# http://trac.videolan.org/vlc/ticket/620
		# causes bus-errors on sparc64-solaris
		$([[ ${CHOST} == *86*-darwin* ]] && echo "--disable-asm")
		$([[ ${CHOST} == sparcv9-*-solaris* ]] && echo "--disable-asm")
		# no cygwin patch yet
		$([[ ${CHOST} == *-cygwin* ]] && \
			echo "gcry_cv_gcc_win64_platform_as_ok=no")

		GPG_ERROR_CONFIG="${EROOT}/usr/bin/${CHOST}-gpg-error-config"
	)
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}" \
		$("${S}/configure" --help | grep -- '--without-.*-prefix' | sed -e 's/^ *\([^ ]*\) .*/\1/g')
}

multilib_src_compile() {
	default
	multilib_is_native_abi && use doc && VARTEXFONTS="${T}/fonts" emake -C doc gcrypt.pdf
}

multilib_src_install() {
	emake DESTDIR="${D}" install
	multilib_is_native_abi && use doc && dodoc doc/gcrypt.pdf
}

multilib_src_install_all() {
	default
	find "${D}" -name '*.la' -delete || die
}
